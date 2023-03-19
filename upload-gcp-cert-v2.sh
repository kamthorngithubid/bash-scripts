#!/bin/bash

path=$(pwd)"/"

rm /var/lib/mysql-files/gcp-all-cert-v2.csv
cp ${path}gcp-all-cert-v2.csv /var/lib/mysql-files/
mysql --login-path=root -e "source ${path}load-gcp-cert-v2.sql;"
