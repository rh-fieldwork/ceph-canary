# ceph-canary

## Overview
There are two (2) major components in this package, a load generator and a metrics collector.

#### Load Generator
  A containerized load generator will run the I/O load against the storage device under test.This will perform the following tasks.
  
  1. Create a persistent volume as the test storage device. 
  2. Run a containerized fio workload with a write and read verification workload against the persistent volume created above.
  3. Clean up the persistent volume and the fio workload containers after the fio job is completed.

#### Metrics Collector
   The metrics collector will collect the metrics generated from the I/O test and export it to the OpenShift Container Platform cluster monitoring stack.
   A containerized prometheus exporter will take the output from the fio job and will expose the collected metrics to the Prometheus server.

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
2. Create the namespace/project in Openshift.
3. Create a service account with admin rights in the namespace.
4. Install the load generator component.
5. Install the metrics collector component.
6. Configure the fio workoad.
7. Configure the prometheus exporter.

### Cloning the git repository
From a workstation c
### Creating the namespace and service account
The default namespace for this project is ceph-canary. Unless necessary, we recommend using the default namespace. To use a different name for the namespace please follow the steps in Appendix A: Changing the namespace name before continuing.

- Log in as an admin user to the api server. 
- Go to the ceph-canary git directory.
- Run the script create_namespace.sh

### Installing the load generator 
Run the script install_loadgen.sh

### Installing the metrics collector
Run the script install_collector.sh

### Configuring the fio job
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
  


Please refer to the fio documentation for the complete list of fio job parameters. 

https://fio.readthedocs.io/en/latest/fio_doc.html


### Configuring the metrics collection


#### Current Metrics Collected
  

#### Sample fio_metrics.conf
    #metric,help,metric name,type,category,item
    bw,Bandwidth Used,bandwidth_avg_KiB_per_second,gauge,write,jobs
    bw_min,Minimum Bandwidth Used,bandwidth_min_KiB_per_second,gauge,write,jobs
    iops_mean,IOPS Mean,iops_mean,gauge,write,jobs
    iops_max,IOPS Max,iops_max,gauge,write,jobs
    iops_min,IOPS Min,iops_min,gauge,write,jobs
    lat_ns/mean,Mean Latency in nanoseconds,latency_mean_nanosecond,gauge,write,jobs
    lat_ns/max,Max latency in nanoseconds,latency_max_nanosecond,gauge,write,jobs
    create_time_ms,PVC creation time in milliseconds,pvc_create_time_milliseconds,gauge,create,pvc



#### Sample fio-results.json
