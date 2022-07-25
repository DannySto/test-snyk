#!/bin/bash

#kubesec-scan.sh

# using kubesec v2 api
scan_result=$(curl -sSX POST --data-binary @"kustomize/base/aas-tools-deploy.yaml" https://v2.kubesec.io/scan)
scan_message=$(curl -sSX POST --data-binary @"kustomize/base/aas-tools-deploy.yaml" https://v2.kubesec.io/scan | jq .[0].message -r ) 
scan_score=$(curl -sSX POST --data-binary @"kustomize/base/aas-tools-deploy.yaml" https://v2.kubesec.io/scan | jq .[0].score ) 


# using kubesec docker image for scanning
# scan_result=$(docker run -i kubesec/kubesec:512c5e0 scan /dev/stdin < kustomize/base/aas-tools-deploy.yaml)
# scan_message=$(docker run -i kubesec/kubesec:512c5e0 scan /dev/stdin < kustomize/base/aas-tools-deploy.yaml | jq .[].message -r)
# scan_score=$(docker run -i kubesec/kubesec:512c5e0 scan /dev/stdin < kustomize/base/aas-tools-deploy.yaml | jq .[].score)

	
    # Kubesec scan result processing
    # echo "Scan Score : $scan_score"

	if [[ "${scan_score}" -ge 5 ]]; then
	    echo "Score is $scan_score"
	    echo "Kubesec Scan $scan_message"
	else
	    echo "Score is $scan_score, which is less than or equal to 5."
	    echo "Scanning Kubernetes Resource has Failed"
	    exit 1;
	fi;