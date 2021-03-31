#!/bin/bash

notify() {
  VARNAME=$1
  echo "*** The variable $VARNAME is not set. Please set and try again. ***"
  exit
}

replace_var() {
  VARNAME=$1
  REPONAME=$2
  FNAME=$3
  if [[ ! -z $(eval echo \$$REPONAME) ]]
  then
    IMAGE=$(eval echo \$$REPONAME | sed 's/\//\\\//g')
    #echo $IMAGE
    if  grep -q $VARNAME $FNAME 
    then 
      sed -i "s/$VARNAME/$IMAGE/g" $FNAME
      if grep -q $(eval echo \$$REPONAME) $FNAME 
      then
        echo "Successfully replaced $VARNAME with $(eval echo \$$REPONAME) in $FNAME."
      else
        echo "*** Failed to replace $VARNAME with $(eval echo \$$REPONAME) in $FNAME. ***"
      fi
    else
      if grep -q $(eval echo \$$REPONAME) $FNAME
      then
        echo "$VARNAME is already replaced with $(eval echo \$$REPONAME) in $FNAME. Skipping ..."
      else
        echo "*** Please verify container image in $FNAME before proceeding to the next step. ***"
      fi
    fi
  else
    notify $REPONAME
  fi
}

# Replace ose-cli image repository variable.
CRONJOB_YAML="fio/fio_cronjob.yaml"
OSECLIPOD_YAML="fio/osecli_pod.yaml"
replace_var OSECLI_IMAGE_REPO osecli_image $CRONJOB_YAML
replace_var OSECLI_IMAGE_REPO osecli_image $OSECLIPOD_YAML 

# Replace the fio container image repository variable.
FIOPOD_YAML="fio/fio_pod.yaml"
replace_var FIOCONTAINER_IMAGE_REPO fiocontainer_image $FIOPOD_YAML
 
# Replace the storage class variable.
FIOLOADPVC_YAML="fio/fio_loadpvc.yaml"
replace_var OCS_STORAGE_CLASS storageclass $FIOLOADPVC_YAML

# Replace prometheus exporter image repository variable.
PROMEXPORTER_YAML="prometheus-exporter/fio-prom-exporter.yaml"
replace_var PROMEXPORTER_IMAGE_REPO promexporter_image $PROMEXPORTER_YAML


