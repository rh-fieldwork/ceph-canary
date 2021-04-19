#!/bin/bash

JOBDIR="/scripts/jobs"
FORMAT="json"
FIO_RESULTS=/tmp/fio-results.json
FIO_ERROR=/tmp/fio-error.log

# Run the fio workload.
cd /tmp 
fio $JOBDIR/fio_job.file --output-format=$FORMAT --output=$FIO_RESULTS 2>$FIO_ERROR

#Append error log to json output
if [[ -s $FIO_ERROR ]]
then
   echo "FIOERROR" >> $FIO_RESULTS
   cat ${FIO_ERROR} >> $FIO_RESULTS
fi

# Write output to pod log.
cat $FIO_RESULTS

