#!/bin/bash

path=$(pwd)"/"

project_id=$1

count_cluster=$(grep ${project_id} ${path}gcp-container-ip.csv|wc -l|awk '{print $1}')

if [[ $count_cluster -gt 1 ]]; then
	echo "Project : ${project_id}, There are ${count_cluster} clusters."
	grep ${project_id} ${path}gcp-container-ip.csv|awk -F "," '{print $2}'|while read cluster_name
	do
		echo "${cluster_name}"
	done
elif [[ $count_cluster -eq 1 ]]; then
	cluster=$(grep ${project_id} ${path}gcp-container-ip.csv |awk -F "," '{print $2}')
	gcloud container clusters get-credentials ${cluster} --region asia-southeast1 --project=${project_id}
fi
