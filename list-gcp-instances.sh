#!/bin/bash

file_instances=gcp-all-instances.csv
path=$(pwd)'/'

echo "PROJECT_ID,NAME,ID,ZONE,MACHINE_TYPE,INTERNAL_IP,EXTERNAL_IP,STATUS" > ../gcp-inventory-data/${file_instances}

gcloud projects list --format="csv[no-heading](project_id)" | while read project_id
do
   check_billing=$(gcloud beta billing projects describe $project_id --format="csv[no-heading](billing_enabled)")
   echo "Project : $project_id, Billing : $check_billing"
   if [ $check_billing == "True" ]
      then
         gcloud compute instances list --quiet  --project=${project_id} --format='csv[no-heading](NAME,ID,ZONE,MACHINE_TYPE,INTERNAL_IP,EXTERNAL_IP,STATUS)' --filter='name !~ gke' | while read instance_name
         do
            echo "${project_id},${instance_name}" >> ../gcp-inventory-data/${file_instances}
         done
   fi
done

