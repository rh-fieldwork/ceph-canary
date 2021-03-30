#!/bin/bash

JOBDIR="/scripts/jobs"
FORMAT="json"
FIO_RESULTS=/tmp/fio-results.json
FIO_ERROR=/tmp/fio-error.log

# Run the fio workload.
cd /tmp 
if fio $JOBDIR/fio_job.file --output-format=$FORMAT --output=$FIO_RESULTS 2>$FIO_ERROR
then
   cat $FIO_RESULTS
else
   cat $FIO_ERROR
   exit 1 
fi

