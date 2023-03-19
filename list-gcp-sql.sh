#!/bin/bash

path=$(pwd)"/"

echo "projectid,name,database_version,location,tier,primary_address,private_address,status" > ../gcp-inventory-data/gcp-all-sql-instances.csv
gcloud projects list --format='csv(project_id)' |awk 'NR!=1' | while read project_id
do
	billing_status=$(gcloud beta billing projects describe $project_id --format='csv(billingEnabled)' |awk 'NR!=1') #|egrep "[tT]rue"|awk -F "," '{print $2}')
    if [[ $billing_status -eq "True" ]]; then
        enabled_service=$(gcloud services list --project=${project_id} |egrep "sqladmin\.googleapis\.com" |awk '{print $1}' |awk -F "." '{print $1}')
        if [[ $enabled_service -eq "sqladmin" ]]; then
            #echo "$project_id,$billing_status,$enabled_service"
            gcloud sql instances list --quiet --project=${project_id} --format='csv(NAME,DATABASE_VERSION,LOCATION,TIER,PRIMARY_ADDRESS,PRIVATE_ADDRESS,STATUS)' |awk 'NR!=1' > ../gcp-inventory-data/.gcp-sql.tmp
            echo "$project_id,$billing_status,$enabled_service,$(wc -l ../gcp-inventory-data/.gcp-sql.tmp |awk '{print $1}') instance(s)."
            cat ../gcp-inventory-data/.gcp-sql.tmp |while read line
            do
                echo "${project_id},${line}" >> ../gcp-inventory-data/gcp-all-sql-instances.csv
            done
        fi
    fi
done