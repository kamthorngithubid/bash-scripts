#!/bin/bash

path=$(pwd)'/'
file_servicelist_enabled=gcp-enabled-services.csv

cat /dev/null > $path$file_servicelist_enabled
echo "PRJECT_ID,NAME,TITLE" > $path$file_servicelist_enabled

gcloud projects list --format='csv(PROJECT_ID,NAME,PROJECT_NUMBER)' |awk -F "," 'NR!=1 {print $1}' | while read project_id
do
 gcloud services list --project $project_id --format='csv(NAME,TITLE)' | awk NR!=1 | sed "s/^/$project_id,/g" >> $path$file_servicelist_enabled
done

