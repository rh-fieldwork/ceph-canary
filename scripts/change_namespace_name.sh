#!/bin/bash

NSNAME=${1:-ceph-canary}

# Change project name variable in scripts
sed -i "s/PROJECT_NAME=\"ceph-canary\"/PROJECT_NAME=\"$NSNAME\"/" scripts/create_project.sh

# Change namespace name in the fio yaml files.
for FNAME in $(ls fio/*)
do
   sed -i "s/namespace: ceph-canary/namespace: $NSNAME/" $FNAME
done

# Change namespace name in the prometheus-exporter yaml files.
for FNAME in $(ls prometheus-exporter/*)
do
   sed -i "s/namespace: ceph-canary/namespace: $NSNAME/" $FNAME
done

# Change namespace name in the project yaml files.
for FNAME in $(ls project/*)
do
   sed -i "s/namespace: ceph-canary/namespace: $NSNAME/" $FNAME
done

