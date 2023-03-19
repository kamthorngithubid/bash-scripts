#!/bin/bash

file_projectname=gcp-all-projects.csv

cat /dev/null > ../gcp-inventory-data/$file_projectname
gcloud projects list --format='csv(project_id,name,project_number,lifecycle_state,create_time)' > ../gcp-inventory-data/$file_projectname