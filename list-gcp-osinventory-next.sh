#!/bin/bash

path=$(pwd)"/"
file_osinventory_json=gcp-all-osinventory.json
file_osinventory_tmp=gcp-all-osconfig.tmp
file_osinventory=gcp-all-osinventory-next.csv

#cat /dev/null > ../gcp-inventory-data/${file_osinventory}
echo 'project_id|available_packages|installed_packages|instance_id|instance_name|os|osconfig_agent_version|update_time' > ../gcp-inventory-data/${file_osinventory}
gcloud projects list --format='csv[no-heading](PROJECT_ID)' |egrep "krungthai\-next" |while read project_id
do
    check=$(gcloud services list --project=${project_id} --format='csv(NAME)' | egrep "osconfig\.googleapis\.com")
    echo "${project_id},${check}"
	if [ ! -z "$check" ]
	    then
            cat /dev/null > ../gcp-inventory-data/${file_osinventory_json}
            for zone in {"asia-southeast1-a","asia-southeast1-b","asia-southeast1-c"}
            do
                gcloud compute os-config inventories list --quiet --project=${project_id} --format=json --location=${zone} > ../gcp-inventory-data/${file_osinventory_json}
                count=$(wc -l ../gcp-inventory-data/${file_osinventory_json} |awk '{print $1}')
	            if [[ $count -gt 5 ]] #-s "../gcp-inventory-data/${file_osinventory_json}"
                    then
                    count=`expr $(wc -l ../gcp-inventory-data/gcp-all-osinventory.json |awk '{print $1}') - 1`
                    awk 'NR!=1' ../gcp-inventory-data/gcp-all-osinventory.json|awk "NR!=${count}" > ../gcp-inventory-data/${file_osinventory_json}.tmp
                    mv ../gcp-inventory-data/${file_osinventory_json}.tmp ../gcp-inventory-data/${file_osinventory_json}
                    python3 ../python-scripts/osinventory.py
                    cat ../gcp-inventory-data/${file_osinventory_tmp} |while read line
                        do
                            echo "${project_id}|${line}" >> ../gcp-inventory-data/${file_osinventory}
                        done
 	            fi
            done
    fi
done
sed "s/\.[0-9]*Z$//g" ../gcp-inventory-data/${file_osinventory} > ../gcp-inventory-data/.${file_osinventory}.tmp
mv ../gcp-inventory-data/.${file_osinventory}.tmp ../gcp-inventory-data/${file_osinventory}

