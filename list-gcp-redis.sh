#!/bin/bash

data="gcp-inventory-data"
file="gcp-regis-instances.csv"
echo "PROJECT_ID,INSTANCE_NAME,VERSION,REGION,TIER,SIZE_GB,HOST,PORT,NETWORK,RESERVED_IP,STATUS,CREATE_TIME" > "../${data}/${file}"
gcloud projects list --format="csv[no-heading](project_id)" |while read project_id
do
    billing_enabled=$(gcloud beta billing projects describe $project_id --format="csv[no-heading](billing_enabled)")
    echo "Project : $project_id, Billing : $billing_enabled"
    if [ $billing_enabled == "True" ]; then
        gcloud redis instances list --quiet --project=${project_id} --region=asia-southeast1 \
        --format="csv[no-heading](INSTANCE_NAME,VERSION,REGION,TIER,SIZE_GB,HOST,PORT,NETWORK,RESERVED_IP,STATUS,CREATE_TIME)" > "../gcp-inventory-data/.test.tmp"
        cat "../gcp-inventory-data/.test.tmp" |while read line
        do
            echo "$project_id,$line" >> "../${data}/${file}"
        done
    fi
done