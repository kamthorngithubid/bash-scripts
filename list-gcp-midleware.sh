#!/bin/bash
data="../gcp-inventory-data/"
echo "project_id,instance_name,location,$1_image_version" > ${data}gcp-$1-instances.csv

#cat $(pwd)"/"test_kafka.csv |awk -F "," '{printf "gcloud compute ssh --tunnel-through-iap --zone=%s %s --project=%s\n", $3, $2, $1;}' \
#|while read -r ssh_cmd
grep  $1 ${data}gcp-all-instances.csv |grep RUNNING |while read line
do
	#echo $ssh_cmd
	#$ssh_cmd -- "sudo docker ps" < /dev/null |egrep "kafka:"
	project_id=$(echo $line |awk -F "," '{print $1}')
	instance=$(echo $line |awk -F "," '{print $2}')
	zone=$(echo $line |awk -F "," '{print $4}')
	a=$(gcloud compute ssh --tunnel-through-iap --zone=${zone} ${instance} --project=${project_id} --command="sudo docker ps" < /dev/null |egrep "(\/$1.*:)" |head -1 |awk '{print $2}')
	#echo "$project_id,$instance,$zone,$a"
	echo "$project_id,$instance,$zone,$a" >> ${data}gcp-$1-instances.csv
done