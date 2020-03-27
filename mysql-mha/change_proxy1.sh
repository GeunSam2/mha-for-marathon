#!/bin/bash
jq .container.docker.image=\"${HAPROXY_IMG_1}\" /etc/mha_script/haproxy.json | \
/usr/local/bin/dcos marathon app update ${MHA_HAPROXY_DCOS_NAME}
echo "HAPROXY update to type 1 success" >> /var/log/masterha/MHA.log
echo "DB Master is now ${MHA_DB_1_IP}${MHA_DB_1_PORT}" >> /var/log/masterha/MHA.log
