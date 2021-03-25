# ceph-canary

## Overview
There are two (2) major components in this package. The first component will run the I/O load against the storage under test and the second one  will collect the metrics generated from the I/O test and export it to the OpenShift Container Platform cluster monitoring stack.


### I/O Load
    1. A container that will run the jobs listed below.
        ◦ Create a persistent volume 
        ◦ Run an fio write with read verification workload against the persistent volume created above
        ◦ Clean up the persistent volume and containers used to tun
    2. A container that will run the fio workload.

### Metrics Collector
    3. A container running the prometheus exporter that exposes the metrics from the fio job for scraping.

## Prerequisites
#### The user workload monitoring must be enabled on the OCP cluster. Please refer to the OpenShift documentation below on how to do this. 

    https://docs.openshift.com/container-platform/4.6/monitoring/enabling-monitoring-for-user-defined-projects.html
    
 #### The cluster must have a ceph rbd storage class.
    $ oc get sc
    NAME                          PROVISIONER                             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
    local-volumes                 kubernetes.io/no-provisioner            Delete          WaitForFirstConsumer   false                  29d
    ocs-storagecluster-ceph-rgw   openshift-storage.ceph.rook.io/bucket   Delete          Immediate              false                  23d
    ocs-storagecluster-cephfs     openshift-storage.cephfs.csi.ceph.com   Delete          Immediate              true                   23d
    openshift-storage.noobaa.io   openshift-storage.noobaa.io/obc         Delete          Immediate              false                  22d
