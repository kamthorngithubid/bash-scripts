#!/bin/bash

path=$(pwd)"/"

echo "PROJECT_ID,NAME,LOCATION,MASTER_VERSION,MASTER_IP,MACHINE_TYPE,NODE_VERSION,NUM_NODES,STATUS" > ${path}gcp-container-ip.csv
gcloud projects list --format='csv(project_id)' |awk 'NR!=1' |egrep "\-prd|\-nonprd|\-prod|\-prod" |while read project_id
do
	echo "${project_id}"
    gcloud container clusters list --region=asia-southeast1 --format='csv(NAME,LOCATION,MASTER_VERSION,MASTER_IP,MACHINE_TYPE,NODE_VERSION,NUM_NODES,STATUS)' --project=${project_id} |awk 'NR!=1' > ${path}gcp-container-ip.tmp
    cat ${path}gcp-container-ip.tmp | while read line
    do
        echo "${project_id},${line}" >> ${path}gcp-container-ip.csv
    done
done
