#!/bin/bash

merge_results() {
  # Get the pvc create time
  CREATE_TIME=$(awk '{print $NF}' $PVC_METRICS)

  # Remove the last 2 lines from the fio results json
  head -n -2 $FIO_OUTPUT > $FIO_RESULTS

  # Append the pvc metrics to the fio metrics json
  echo "  ]," >> ${FIO_RESULTS}
  echo "  \"pvc\" : [" >> ${FIO_RESULTS}
  echo "    {" >> ${FIO_RESULTS}
  echo "      \"name\" : \"fio-load-pvc\"," >> ${FIO_RESULTS}
  echo "      \"create\" : {" >> ${FIO_RESULTS}
  echo "        \"create_time_ms\" : ${CREATE_TIME}" >> ${FIO_RESULTS} 
  echo "      }" >> ${FIO_RESULTS} 
  echo "    }" >> ${FIO_RESULTS}
  echo "  ]" >> ${FIO_RESULTS}
  echo "}" >> $FIO_RESULTS 
}

WORKDIR="/mnt/fio"
JOBDIR="/scripts/jobs"
FORMAT="json"
    
FIO_OUTPUT=/tmp/fio-results.json
PVC_METRICS=$WORKDIR/pvc_metrics.txt
FIO_RESULTS=$WORKDIR/fio-results.json

# Run the fio workload.
cd /tmp 
fio $JOBDIR/fio_job.file --output-format=$FORMAT --output=$FIO_OUTPUT

if [[ -f $PVC_METRICS ]]
then
  # Merge the pvc creation metrics with the fio results.
  merge_results
else
  echo "$PVC_METRICS not found. Sending only the fio output to the prometheus client."
  cp $FIO_OUTPUT $FIO_RESULTS
fi

# Make the fio results available to the fio-pod log. 
cat $FIO_RESULTS
