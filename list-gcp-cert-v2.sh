#!/bin/bash

dt=$(date +"%Y%m%d")
file_ssl=gcp-all-cert.csv
file_tmp=$(pwd)"/tmp_cert.tmp"
log=log-cert.log
path=$(pwd)"/"

#PART 1, List all certificate data from all Projects.
cat /dev/null > $path$file_ssl
#echo "PROJECT_ID,NAME,TYPE,CREATION_TIMESTAMP,EXPIRE_TIME,MANAGE_STATUS" > $path$file_ssl
cat /dev/null > $path$log
cat /dev/null > ${path}gcp-all-cert-v2.csv

mysql --login-path=root -e "use inventory; select projectid from gcpbillingstatus where billingenabled='true';" > ${path}project_id_file.tmp
awk 'NR!=1' ${path}project_id_file.tmp | while read project_id
do
	#echo "${project_id}"
	gcloud compute ssl-certificates list --project=${project_id} --format=json > ${path}temp_cert.json
	if [ $(wc -l ${path}temp_cert.json |awk '{print $1}') -gt 1 ]
	then
		python3 ${path}cert-read-json.py
		cat gcp-all-cert-v2.tmp | while read line
			do
				echo "${project_id}|${line}" >> ${path}gcp-all-cert-v2.csv
			done
		#cat ${path}temp_cert.json |jq -r '.[] | [.creationTimestamp, .expireTime, .id, .kind, .name, .type, .subjectAlternativeNames[]] | @csv' > ${path}gcp-all-cert-v2.tmp
		#cat ${path}gcp-all-cert-v2.tmp |awk '{print $project_id","$0}' >> ${path}gcp-all-cert-v2.csv
	fi
done

sed "s/, /,/g" ${path}gcp-all-cert-v2.csv |sed "s/\['/\"/g" |sed "s/'\]/\"/g" | sed "s/','/\",\"/g" > ${path}gcp-all-cert-v2.tmp
mv ${path}gcp-all-cert-v2.tmp ${path}gcp-all-cert-v2.csv
