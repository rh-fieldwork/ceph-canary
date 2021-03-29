# ceph-canary

## Overview
---Insert brief description and process flow here


---Insert diagram here

There are two (2) major components in this package, a load generator and a metrics collector.

#### Load Generator
  A containerized load generator will run the I/O load against the storage device under test.This will perform the following tasks.
  
  1. Create a persistent volume as the test storage device. 
  2. Run a containerized fio workload (fio/run_fio.sh) with a write and read verification workload against the persistent volume created above.
  3. Clean up the persistent volume and the fio workload containers after the fio job is completed.

--- Insert brief description of fio tool here.

#### Metrics Collector
   The metrics collector will collect the metrics generated from the I/O test and export it to the OpenShift Container Platform cluster monitoring stack.
   A containerized prometheus exporter app (prometheus-exporter/prometheusclient.py) will take the output from the fio job and will expose the collected metrics to the Prometheus server.

--- Insert brief description of prometheus client here.
## Requirements
  1. The user workload monitoring must be enabled on the OCP cluster. Please refer to the OpenShift documentation below on how to do this.
     
     https://docs.openshift.com/container-platform/4.6/monitoring/enabling-monitoring-for-user-defined-projects.html

  2. The cluster must have a ceph rbd storage class. 
   
    
    
    $ oc get sc
    NAME                          PROVISIONER                             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
    local-volumes                 kubernetes.io/no-provisioner            Delete          WaitForFirstConsumer   false                  29d
    ocs-storagecluster-ceph-rbd   openshift-storage.rbd.csi.ceph.com      Delete          Immediate              true                   23d
    ocs-storagecluster-ceph-rgw   openshift-storage.ceph.rook.io/bucket   Delete          Immediate              false                  23d
    ocs-storagecluster-cephfs     openshift-storage.cephfs.csi.ceph.com   Delete          Immediate              true                   23d
    openshift-storage.noobaa.io   openshift-storage.noobaa.io/obc         Delete          Immediate              false                  22d

  3. The following images must be present in the cluster repository
  4. A workstation or bastion host with oc cli client and git installed. It must have access to the OCP cluster where ceph-canary will be installed.

## Installation Steps
1. Clone the ceph-canary git repository.
2. Create the project namespace and service account in Openshift.
3. Install the metrics collector component.
4. Install the load generator component.
5. Modify the fio workoad. (Optional)
6. Modify the fio metrics collected. (Optional)

### Step 1. Cloning the git repository.
From the workstation, create a directory to clone the git repo to. Replace "\<local-repo\>" with the desired directory name.

    $ sudo mkdir -p ~/<localrepo>
    $ cd ~/<localrepo>

Clone the ceph-canary repo.

    $ git clone https://github.com/jsangeles61/ceph-canary.git
    Cloning into 'ceph-canary'...
    remote: Enumerating objects: 207, done.
    remote: Counting objects: 100% (207/207), done.
    remote: Compressing objects: 100% (203/203), done.
    remote: Total 207 (delta 62), reused 0 (delta 0), pack-reused 0
    Receiving objects: 100% (207/207), 53.12 KiB | 2.41 MiB/s, done.
    Resolving deltas: 100% (62/62), done.

    $ ls -l ceph-canary
    total 8
    drwxrwxr-x. 2 jangeles jangeles  189 Mar 26 15:04 fio
    drwxrwxr-x. 2 jangeles jangeles  159 Mar 26 15:04 prometheus-exporter
    -rw-rw-r--. 1 jangeles jangeles 4933 Mar 26 15:04 README.md

### Step 2. Creating the namespace and service account.
The default namespace for this project is ceph-canary. Unless necessary, we recommend using the default namespace. To use a different name for the namespace please follow the steps in Appendix A: How to Change the Name of the Namespace before continuing.

- Log in as an admin user to the api server. 

- Go to the ceph-canary git directory.
            
      $ cd ~/<localrepo>/ceph-canary
  
- Run the script create_project.sh
  
      $ ./create_project.sh
      namespace/ceph-canary created
      serviceaccount/ceph-canary created
      role.rbac.authorization.k8s.io/ceph-canary created
      rolebinding.rbac.authorization.k8s.io/ceph-canary created
      Now using project "ceph-canary" on server "https://<api-server>:6443"
     
 - Verify that the ceph-canary role and rolebinding are created.

        $ oc get sa
        NAME          SECRETS   AGE
        builder       2         46s
        ceph-canary   2         46s
        default       2         46s
        deployer      2         46s
        
        # oc get role
        NAME          CREATED AT
        ceph-canary   <creation timestamp>

        
        $ oc get rolebindings
        NAME                    ROLE                               AGE
        ceph-canary             Role/ceph-canary                   54s
        system:deployers        ClusterRole/system:deployer        54s
        system:image-builders   ClusterRole/system:image-builder   54s
        system:image-pullers    ClusterRole/system:image-puller    54s

### Step 3. Installing the metrics collector.
Run the script install_collector.sh

        $ scripts/install_exporter.sh
        configmap/fio-metrics-conf created
        configmap/fio-prom-client created
        deployment.apps/fio-prom-exporter created
        service/fio-prom-exporter created
        servicemonitor.monitoring.coreos.com/fio-monitor created

The prometheus exporter pod and servoce monitor should be running now. To verify,

        $ oc get po
        NAME                                 READY   STATUS    RESTARTS   AGE
        fio-prom-exporter-<xxxxxxxxxx-xxxxx>   1/1     Running   0          76s
        
        $ oc get servicemonitor
        NAME          AGE
        fio-monitor   3m31s

### Step 4. Installing the load generator. 
Run the script install_loadgen.sh

    # scripts/install_loadgen.sh
    configmap/fio-job created
    configmap/fio-run created
    configmap/fio-pod created
    configmap/fio-canary created
    configmap/fio-load-pvc created
    cronjob.batch/fio-cronjob created

Verify if the cronjob is created.
    
    # oc get cronjobs
    NAME          SCHEDULE       SUSPEND   ACTIVE   LAST SCHEDULE   AGE
    fio-cronjob   */10 * * * *   False     0        <none>          34s

### Step 5. Modifying the fio workload.
The default fio job (fio/fio_job.file) has the following global and job parameters defined.

    [global]
    name=ceph_canary_test
    directory=/mnt/pvc
    filename_format=f.\$jobnum.\$filenum
    write_bw_log=fio
    write_iops_log=fio
    write_lat_log=fio
    write_hist_log=fio
    log_avg_msec=1000
    log_hist_msec=1000
    clocksource=clock_gettime
    kb_base=1000
    unit_base=8
    ioengine=libaio
    size=1GiB
    bs=1024KiB
    rate_iops=200
    iodepth=1
    direct=1
    numjobs=1
    ramp_time=5
    
    [write]
    rw=write
    fsync_on_close=1
    create_on_open=1
    verify=sha1
    do_verify=1
    verify_fatal=1
  

To modify the workload, edit the configmap fio-job. 

    $ oc edit configmap fio-metrics-conf

Please refer to the fio documentation for the complete list of fio job parameters. 

https://fio.readthedocs.io/en/latest/fio_doc.html


### Step 6. Modifying the metrics collection.
The default metrics selected from the fio results are defined in the confgimap fio-job. The defaults metrics collected include: 
- Average bandwidth in KiB per second
- Minimum bandwidth in Kib per second
- Mean IOPS
- Maximum IOPS
- Minimum IOPS
- Mean write latency in nanoseconds
- Maximum write latency in nanoseconds
- Time to create a persistent volume claim in milliseconds

To modify the list of metrics collected and exposed by the prometheus client, edit the configmap fio-metrics-conf.

    $ oc edit configmap fio-metrics-conf

Please refer to the default fio_metrics.conf below for the format of the config file and to the sample fio-results.json file for all metrics available from the fio job output. 

#### Fio metrics config file fields.
- metric: The metric collected from the FIO job. This corresponds to the 3rd level data in the json output. (Example: jobs-->write-->iops_mean)
- help: Prometheus help string.
- metric name: Prometheus metric name.
- type: Prometheus metric type - counter,gauge, summary and histogram
- category: FIO json output 2nd level data. (Example: jobs-->write)
- item: FIO json output 1st level data. (Example: jobs or pvc)

Please refer to the Prometheus documentation for more details on the data exposed by the prometheus client/exporter..
https://prometheus.io/docs/introduction/overview/

#### Default fio_metrics.conf
    #metric,help,metric name,type,category,item
    Bandwidth Used,bandwidth_avg_KiB_per_second,gauge,write,jobs
    bw_min,Minimum Bandwidth Used,bandwidth_min_KiB_per_second,gauge,write,jobs
    iops_mean,IOPS Mean,iops_mean,gauge,write,jobs
    iops_max,IOPS Max,iops_max,gauge,write,jobs
    iops_min,IOPS Min,iops_min,gauge,write,jobs
    lat_ns/mean,Mean Latency in nanoseconds,latency_mean_nanosecond,gauge,write,jobs
    lat_ns/max,Max latency in nanoseconds,latency_max_nanosecond,gauge,write,jobs
    create_time_ms,PVC creation time in milliseconds,pvc_create_time_milliseconds,gauge,create,pvc

#### Sample fio-results.json
   https://github.com/jsangeles61/ceph-canary/blob/main/prometheus-exporter/fio-results.json

### Prometheus scrape interval.
To modify the prometheus scraping interval for the fio enpoint, edit the service monitorfio-monitor.

    # oc edit servicemonitor fio-monitor


## Appendix A: How to Change the Name of the Namespace

