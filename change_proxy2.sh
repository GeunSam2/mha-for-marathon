#!/bin/bash
. /env.sh
jq .container.docker.image=\"${MHA_HAPROXY_IMG_2}\" /etc/mha_script/haproxy.json | \
/usr/local/bin/dcos marathon app update ${MHA_HAPROXY_DCOS_NAME}
echo "HAPROXY update to type 2 success" >> /var/log/masterha/MHA.log
echo "DB Master is now ${MHA_DB_2_IP}${MHA_DB_2_PORT}" >> /var/log/masterha/MHA.log
