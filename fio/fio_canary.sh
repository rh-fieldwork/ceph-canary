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
    echo "pvc_create_time_milliseconds $pvc_create_time_ms" > ${PVC_METRICS}
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

send_error_message() {
   cd $DATADIR
   if [[ -f ${FIO_OUTPUT}1 ]]
   then
     mv ${FIO_OUTPUT}1 ${FIO_ERROR}
     echo "Error encountered on fio job. Copying ${FIO_ERROR} to prometheus exporter."
     cat ${FIO_ERROR}
     oc cp $FIO_ERROR ${PROMEXPORTER}:$DESTDIR
   fi
}

merge_results() {
  # Extract the error message from the fio pod log, if any.
  cd $DATADIR
  awk '/FIOERROR/{i++}{print > "fio-output.json"i}' $FIO_POD_LOG 

  # Get the pvc create time
  CREATE_TIME=$(awk '{print $NF}' $PVC_METRICS)

  # Remove the last 2 lines from the fio results json
  head -n -2 $FIO_OUTPUT > $FIO_RESULTS

  # Append the pvc metrics to the fio metrics json
  echo "  ]," >> ${FIO_RESULTS}
  echo "  \"ocs\" : [" >> ${FIO_RESULTS}
  echo "    {" >> ${FIO_RESULTS}
  echo "      \"name\" : \"fio-load-pvc\"," >> ${FIO_RESULTS}
  echo "      \"pvc\" : {" >> ${FIO_RESULTS}
  echo "        \"create_time_ms\" : ${CREATE_TIME}" >> ${FIO_RESULTS}
  echo "      }" >> ${FIO_RESULTS}
  echo "    }" >> ${FIO_RESULTS}
  echo "  ]" >> ${FIO_RESULTS}
  echo "}" >> $FIO_RESULTS
}


run_fio() {
  if oc create -f $CREATE_FIO_CONTAINER
  then
    # Wait until fio container/workload is completed.
    echo "Waiting for the fio workload to complete."
    sleep 10
    while true
    do
      FIO_STATUS=$(oc get po fio-pod |grep ^fio-pod |awk '{print $3}')
      case ${FIO_STATUS} in
        Completed ) 
            echo "FIO workload completed."
            break;;
        Error )
            echo "Error encountered in fio pod."
            break;;
        Running|ContainerCreating )
            echo "fio job still running."      
            ;;
        * )
            echo "Unknown status. Please check state of fio-pod."
            ;;
      esac 
      sleep 10
    done

    # Get the fio metrics json from the fio-pod.
    cd $DATADIR
    if oc logs $FIO_POD > $FIO_POD_LOG
    then
        echo "Succesfully retrieved fio output from the fio pod."
    else
        echo "Failed to retrieve fio output from the fio pod."
        exit
    fi

    # Delete the fio-pod.
    oc delete pod $FIO_POD 

  else
    echo "Failed to start fio container."
    exit
  fi
}

send_results() {
  while true
  do
    #Get the prometheus exporter pod name
    PROMEXPORTER=$(oc get po|grep fio-prom-exporter|grep Running|awk '{print $1}')
    if [ -z $PROMEXPORTER ]
    then
      echo "$PROMEXPORTER is not running. Waiting for exporter..."
      sleep 60
    else
      if oc cp $FIO_RESULTS ${PROMEXPORTER}:$DESTDIR
      then
         echo "$FIO_RESULTS copied to ${PROMEXPORTER}:$DESTDIR"
         send_error_message
         break
      else
         echo "*** Failed to copy $FIO_RESULTS to ${PROMEXPORTER}:$DESTDIR"
         exit
      fi
   fi
  done
}

DESTDIR=/tmp/data
DATADIR="/tmp/data"
mkdir -p $DATADIR

PVC_METRICS=$DATADIR/pvc_metrics.txt
FIO_OUTPUT=$DATADIR/fio-output.json
FIO_RESULTS=$DATADIR/fio-results.json
FIO_POD_LOG=$DATADIR/fio-pod.log
FIO_POD="fio-pod"
FIO_ERROR="fio-error.log"

CREATE_PVC="/fio/config-fioloadpvc/fio_loadpvc.yaml"
CREATE_FIO_CONTAINER="/fio/config-fiopod/fio_pod.yaml"

# Create persistent volume claim for fio workload.
create_pvc

# Run the fio workload
run_fio

# Delete the persistent volume claim
delete_pvc

# Merge the pvc and fio metrics.
merge_results

#Send the merged metrics to the prometheus exporter.
send_results

