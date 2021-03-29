#!/bin/bash

PROJECT_NAME="ceph-canary"

# Create the namespace
oc create namespace $PROJECT_NAME 

# Create the service account
oc create sa ceph-canary -n $PROJECT_NAME 

# Create a local role
oc create -f project/ceph-canary_role.yaml

# Create rolebinding
oc create -f project/ceph-canary_rolebinding.yaml

# Go to project 
oc project $PROJECT_NAME 


