#!/bin/bash

dt=$(date +"%Y%m%d")
file_projectname=gcp-all-projects.csv
file_enabled_srv=gcp-enabled-services.csv
file_ssl=gcp-all-ssl.csv
file_tmp=$(pwd)"/tmp_ssl.tmp"
log=log-ssl.log
path=$(pwd)'/'

cat /dev/null > $path$file_ssl
echo "PROJECT_ID,NAME,TYPE,CREATION_TIMESTAMP,EXPIRE_TIME,MANAGE_STATUS" > $path$file_ssl
cat /dev/null > $path$log
awk NR!=1 $path$file_enabled_srv | grep compute.googleapis.com | awk -F "," '{print $1}' | while read project_id
do
 cat /dev/null > $file_tmp
 #gcloud compute ssl-certificates list --project $project_id --format='csv(NAME,TYPE,CREATION_TIMESTAMP,EXPIRE_TIME,MANAGE_STATUS)' | awk NR!=1 > $file_tmp
 gcloud compute ssl-certificates list --project $project_id | awk NR!=1 > $file_tmp
 if [ -s "$file_tmp" ]; then
    awk '{print $1","$2","$3","$4","$5}' $file_tmp | sed "s/:,/,/g" | sed "s/^/$project_id,/g" >> $path$file_ssl
 fi
done
rm $file_tmp