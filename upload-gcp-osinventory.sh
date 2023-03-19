#!/bin/bash

path=$(pwd)"/"

#rm /var/lib/mysql-files/gcp-all-osinventory.csv
#cp ${path}gcp-os-inventory.csv /var/lib/mysql-files/
mysql --login-path=root -e "source ${path}load-gcp-osinventory.sql;"

