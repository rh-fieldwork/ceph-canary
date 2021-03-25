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


