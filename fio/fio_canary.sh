#!/bin/bash

create_pvc() {
  start_time=$(date +%s%N)
  if oc create -f ${CREATE_PVC}    
  then
    while true
    do
      if oc get pvc fio-load-pvc| grep -q Bound
      then
        break
      fi
    done
    end_time=$(date +%s%N)
    echo "persistentvolumeclaim/fio-load-pvc created."
    pvc_create_time_ms=$(( $((end_time-start_time)) / 1000000 ))
    echo "$(date +%X): PVC Creation Time = $pvc_create_time_ms milliseconds."
    echo "pvc_create_time_ms $pvc_create_time_ms" > ${PVC_METRICS}
  else
    echo "Failed to create persistentvolumeclaim/fio-load-pvc."
    exit
  fi
}

delete_pvc() {
  if oc get pvc fio-load-pvc| grep -q Bound
  then
    if oc delete -f ${CREATE_PVC}
    then
      # Wait until the pvc is deleted
      while true 
      do
        oc get pvc fio-load-pvc 2>/dev/null
        if [[ $? ]]
        then
          echo "persistentvolumeclaim/fio-load-pvc deleted."
          break
        else
          echo "PVC deletion in progress.."
          sleep 1
        fi
      done
    fi
  fi
}

run_fio() {
  if oc create -f $CREATE_FIO_CONTAINER
  then
    # Wait until fio container/workload is completed.
    echo "Waiting for the fio workload to complete."
    while true
    do
      if oc get po fio-pod | grep Completed
      then
        echo "FIO workload completed."
        break
      fi
      echo "Waiting ....."
      sleep 10
    done

    # Delete the fio-pod.
    oc delete pod fio-pod
  else
    echo "Failed to start fio container."
    exit
  fi
}

CREATE_PVC="/mnt/config-fioloadpvc/fio_loadpvc.yaml"
CREATE_FIO_CONTAINER="/mnt/config-fiopod/fio_pod.yaml"
PVC_METRICS=/mnt/fio/pvc_metrics.txt

# Create persistent volume claim for fio workload.
create_pvc

# Run the fio workload
run_fio

# Delete the persistent volume claim
delete_pvc

