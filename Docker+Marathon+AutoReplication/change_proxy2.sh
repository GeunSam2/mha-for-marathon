#!/bin/bash
echo "HAPROXY update to type 2 success" >> /var/log/masterha/MHA.log
dcos marathon app update ${MHA_HAPROXY_DCOS_NAME} < /etc/mha_script/app2.json
