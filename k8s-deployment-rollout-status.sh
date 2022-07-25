#!/bin/bash

rancher login https://${RANCHER_URL} --token ${RANCHER_TOKEN} --context ${PROJECT_ID}

sleep 60s

if [[ $(rancher kubectl -n $NAMESPACE rollout status deploy ${PROJECT} --timeout 5s) != *"successfully rolled out"* ]]; 
then     
	echo "Deployment ${PROJECT} Rollout has Failed"
    rancher kubectl -n $NAMESPACE rollout undo deploy ${PROJECT}
    exit 1;
else
	echo "Deployment ${PROJECT} Rollout is Success"
fi