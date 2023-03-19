#!/bin/bash

mkdir /ops_script

mkdir /var/log/psmongodb_status

touch /var/log/psmongodb_status/psmongodb_status.log

touch /ops_script/psmongodb_status.sh && cat /dev/null > /ops_script/psmongodb_status.sh

tee -a /ops_script/psmongodb_status.sh << EOF
PROCESS_NAME=("mongod" "mongos")
SCODE=MG0000  #App code
FCODE=MG9999  #App code
for process_name in \${PROCESS_NAME[@]}
do
 RUNNING=\$(ps -C \$process_name |grep -v PID |head -n 1|awk '{print \$4}' 2> /dev/null)
 if [ \$RUNNING == \$process_name ]; then
  echo "\$SCODE Process MongoDB - \$process_name state is running. @time:\`date\`" >>/var/log/psmongodb_status/psmongodb_status.log
 else
  echo "\$FCODE Process MongoDB - \$process_name state is not running.!!!!!! @time:\`date\`" >>/var/log/psmongodb_status/psmongodb_status.log
fi
done
EOF

cd /ops_script && chmod +x psmongodb_status.sh;

mv /etc/google-cloud-ops-agent/config.yaml /etc/google-cloud-ops-agent/config.yaml.bak

touch /etc/google-cloud-ops-agent/config.yaml

tee -a /etc/google-cloud-ops-agent/config.yaml << EOF
logging:
  receivers:
    mongodb:
      type: mongodb
      include_paths:
        - /data/mongo/log/router/mongod.log
        - /data/mongo/log/config/mongod.log
    psmongodb_status:
      type: files
      include_paths:
        - /var/log/psmongodb_status/psmongodb_status.log
  processors:
    psmongodb_status:
      type: parse_json

  service:
    pipelines:
      mongodb:
        receivers:
          - mongodb
      psmongodb_status:
        receivers:
          - psmongodb_status
        processors:
          - psmongodb_status
EOF
bash /ops_script/psmongodb_status.sh
systemctl restart google-cloud-ops-agent