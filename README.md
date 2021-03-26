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
  4. A workstation or bastion host with oc cli client and got installed. It mus also have access to the OCP cluster where ceph-canary will be installed.

## Installation Steps
1. Clone the ceph-canary git repository.
2. Create the namespace/project in Openshift.
3. Create a service account with admin rights in the namespace.
4. Install the load generator component.
5. Install the metrics collector component.
6. Configure the fio workoad.
7. Configure the prometheus exporter.

### Cloning the repository
From a workstation 
### Creating the namespace and service account
The default namespace for this project is ceph-canary. Unless necessary, we recommend using the default namespace. To use a different name for the namespace please follow the steps in Appendix A: Changing the namespace name before continuing.

- Log in as an admin user to the api server. 
- Go to the ceph-canary git directory.
- Run the script create_namespace.sh

### Cloning the git repository

### Installing the load generator 

### Installing the metrics collector

### Configuring the fio job

### Configuring the metrics collection


