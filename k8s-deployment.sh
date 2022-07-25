#!/bin/bash

sed -i "s/%%VERSION%%/$VERSION/" kustomize/base/aas-tools-deploy.yaml
rancher login https://${RANCHER_URL} --token ${RANCHER_TOKEN} --context ${PROJECT_ID}
rancher kubectl -n $NAMESPACE get deployment ${PROJECT}  > /dev/null

if [[ $? -ne 0 ]]; then
    echo "deployment ${PROJECT}  doesnt exist"
    rancher kubectl apply -k kustomize/overlays/$ENV
else
    echo "deployment ${PROJECT}  exist"
    echo "image name - $ARTIFACTORY_URL/$TEAM_PREFIX/$PROJECT:$VERSION"
    # rancher kubectl -n $NAMESPACE set image deployment ${PROJECT} $IMAGENAME=$ARTIFACTORY_URL/$TEAM_PREFIX/$PROJECT:$VERSION --record=true
    rancher kubectl apply -k kustomize/overlays/$ENV --record=true
    rancher kubectl -n $NAMESPACE rollout restart deployment ${PROJECT}
fi