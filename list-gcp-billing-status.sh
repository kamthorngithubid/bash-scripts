#!/bin/bash

path=$(pwd)"/"
i=1
gcloud projects list --format='csv[no-heading](project_id)' | while read project_id
do

    if [ $i -eq 1 ]; then
        gcloud beta billing projects describe $project_id --format='csv(projectId,billingEnabled)' > ../gcp-inventory-data/gcp-all-projects-billinginfo.csv
        i=`expr $i + 1`
    else
        gcloud beta billing projects describe $project_id --format='csv[no-heading](projectId,billingEnabled)' >> ../gcp-inventory-data/gcp-all-projects-billinginfo.csv
    fi
done