#!/bin/bash

# Create the configmap for the fio job file
oc create configmap fio-job --from-file=fio/fio_job.file

# Create the configmap for the fio run script
oc create configmap fio-run --from-file=fio/run_fio.sh

# Create the configmap for the fio pod
oc create configmap fio-pod --from-file=fio/fio_pod.yaml

# Create the configmap for the main fio-canary script
oc create configmap fio-canary --from-file=fio/fio_canary.sh

# Create the configmap for the fio load pvc 
oc create configmap fio-load-pvc --from-file=fio/fio_loadpvc.yaml

# Create the Cronjob 
oc create -f fio/fio_cronjob.yaml

