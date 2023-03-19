#!/bin/bash
data="../gcp-inventory-data/"
echo "project_id,instance_name,location,os_distro,server_type,$1_version" > ${data}gcp-$1-instances.csv

#cat $(pwd)"/"test_kafka.csv |awk -F "," '{printf "gcloud compute ssh --tunnel-through-iap --zone=%s %s --project=%s\n", $3, $2, $1;}' \
#|while read -r ssh_cmd
grep  $1 ${data}gcp-all-instances.csv |grep RUNNING |while read line
do
	#echo $ssh_cmd
	#$ssh_cmd -- "sudo docker ps" < /dev/null |egrep "kafka:"
	project_id=$(echo $line |awk -F "," '{print $1}')
	instance=$(echo $line |awk -F "," '{print $2}')
	zone=$(echo $line |awk -F "," '{print $4}')
	
	#Below statement using for checking the MongoDB server type, ROUTER or SHARD
	if [[ `echo $instance |awk -F "-" '{print $NF}'|cut -c 1 ` = "r" ]]; then
		mongodb_server_type="ROUTER"
	elif [[ `echo $instance |awk -F "-" '{print $NF}'|cut -c 1 ` = "s" ]]; then
		mongodb_server_type="SHARD"
	fi
	
	#Below statement using for checking the Linux Distro like a "Ubunt" or "CentOS"
	os_distro_pretty_name=`gcloud compute ssh --tunnel-through-iap --zone=${zone} ${instance} --project=${project_id} --command='cat /etc/*release|grep PRETTY_NAME|cut -d = -f 2' < /dev/null`
	os_distro_short_name=`echo $os_distro_pretty_name|sed 's/"//g'|awk '{print $1}'`
	
	#Below statement using for checking the MongoDB version
	if [[ $os_distro_short_name = "CentOS" ]]; then
		a=`gcloud compute ssh --tunnel-through-iap --zone=${zone} ${instance} --project=${project_id} --command='mongod --version' < /dev/null |head -1|awk '{print $3}'`
	elif [[ $os_distro_short_name = "Ubuntu" ]] && [[ $mongodb_server_type = "ROUTER" ]]; then
		a=`gcloud compute ssh --tunnel-through-iap --zone=${zone} ${instance} --project=${project_id} --command='mongo --version' < /dev/null |head -1|awk '{print $4}'`
	elif [[ $os_distro_short_name = "Ubuntu" ]] && [[ $mongodb_server_type = "SHARD" ]]; then
		a=`gcloud compute ssh --tunnel-through-iap --zone=${zone} ${instance} --project=${project_id} --command='mongod --version' < /dev/null |head -1|awk '{print $3}'`
	fi
	echo "$project_id,$instance,$zone,$os_distro_pretty_name,$mongodb_server_type,$a" >> ${data}gcp-$1-instances.csv
done