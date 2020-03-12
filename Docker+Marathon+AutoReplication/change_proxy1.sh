#!/bin/bash
echo "HAPROXY update to type 1 success" >> /var/log/masterha/MHA.log
/usr/local/bin/dcos marathon app update ${MHA_HAPROXY_DCOS_NAME} < /etc/mha_script/app1.json
