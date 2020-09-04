#!/bin/bash
####
#Check ENV
####
echo "### Checking ENV"
if [ -z ${MHA_DB_1_IP} ] || \
[ -z ${MHA_DB_2_IP} ] || \
[ -z ${MHA_DB_3_IP} ] || \
[ -z ${MHA_DB_4_IP} ] || \
[ -z ${MHA_DB_1_PORT} ] || \
[ -z ${MHA_DB_2_PORT} ] || \
[ -z ${MHA_DB_3_PORT} ] || \
[ -z ${MHA_DB_4_PORT} ] || \
[ -z ${MHA_DB_1_SSH_PORT} ] || \
[ -z ${MHA_DB_2_SSH_PORT} ] || \
[ -z ${MHA_DB_3_SSH_PORT} ] || \
[ -z ${MHA_DB_4_SSH_PORT} ] || \
[ -z ${MHA_REPL_DB_1} ] || \
[ -z ${MHA_DCOS_URL} ] || \
[ -z ${MHA_DCOS_ID} ] || \
[ -z ${MHA_DCOS_PW} ] || \
[ -z ${MHA_HAPROXY_DCOS_NAME} ] || \
[ -z ${MHA_DB_ADMIN_ID} ] || \
[ -z ${MHA_DB_ADMIN_PW} ] || \
[ -z ${MHA_DB_REPL_ID} ] || \
[ -z ${MHA_DB_REPL_PW} ];then
        echo "[Error] Make sure that all environment variables are set."
        exit 1
fi
MHA_DB_1="${MHA_DB_1_IP}:${MHA_DB_1_PORT}"
MHA_DB_2="${MHA_DB_2_IP}:${MHA_DB_2_PORT}"
MHA_DB_3="${MHA_DB_3_IP}:${MHA_DB_3_PORT}"
MHA_DB_4="${MHA_DB_4_IP}:${MHA_DB_4_PORT}"
MHA_REPL_LIST=(${MHA_DB_1} ${MHA_DB_2} ${MHA_DB_3} ${MHA_DB_4})
MHA_CMASTER_IP=""
MHA_CMASTER_PORT=""
MHA_CMASTER=""

#Dump ENVS for cron
echo '#!/bin/bash' > /env.sh
set | grep ^MHA_ >> /env.sh
chmod 775 /env.sh

#DCOS SETUP
echo "### DCOS CLUSTER SETUP"
dcos cluster setup ${MHA_DCOS_URL} --insecure --username ${MHA_DCOS_ID} --password ${MHA_DCOS_PW}

echo "### Checking ENV [OK]"

echo "###Wait MHA Nodes for 10 Second "
sleep 10

#Check Current Master and Slave status
echo "### Checking Current Master and Slave Status"
if [ $(mysql -h ${MHA_DB_1_IP} -P ${MHA_DB_1_PORT} -u${MHA_DB_ADMIN_ID} -p${MHA_DB_ADMIN_PW} -e "show slave status\G" | grep "Waiting for master to send event" | wc -l) -eq 1 ]; then
        MHA_CMASTER_IP=$(mysql -h ${MHA_DB_1_IP} -P ${MHA_DB_1_PORT} -u${MHA_DB_ADMIN_ID} -p${MHA_DB_ADMIN_PW} -e "show slave status\G" | grep Master_Host | awk -F": " '{print $2}')
        MHA_CMASTER_PORT=$(mysql -h ${MHA_DB_1_IP} -P ${MHA_DB_1_PORT} -u${MHA_DB_ADMIN_ID} -p${MHA_DB_ADMIN_PW} -e "show slave status\G" | grep Master_Port | awk -F": " '{print $2}')
        MHA_CMASTER=${MHA_CMASTER_IP}:${MHA_CMASTER_PORT}
        MHA_REPL_LIST=("${MHA_REPL_LIST[@]/${MHA_DB_1}/}")
        MHA_REPL_LIST=("${MHA_REPL_LIST[@]/${MHA_CMASTER}/}")
fi
if [ $(mysql -h ${MHA_DB_2_IP} -P ${MHA_DB_2_PORT} -u${MHA_DB_ADMIN_ID} -p${MHA_DB_ADMIN_PW} -e "show slave status\G" | grep "Waiting for master to send event" | wc -l) -eq 1 ]; then
        MHA_CMASTER_IP=$(mysql -h ${MHA_DB_2_IP} -P ${MHA_DB_2_PORT} -u${MHA_DB_ADMIN_ID} -p${MHA_DB_ADMIN_PW} -e "show slave status\G" | grep Master_Host | awk -F": " '{print $2}')
        MHA_CMASTER_PORT=$(mysql -h ${MHA_DB_2_IP} -P ${MHA_DB_2_PORT} -u${MHA_DB_ADMIN_ID} -p${MHA_DB_ADMIN_PW} -e "show slave status\G" | grep Master_Port | awk -F": " '{print $2}')
        MHA_CMASTER=${MHA_CMASTER_IP}:${MHA_CMASTER_PORT}
        MHA_REPL_LIST=("${MHA_REPL_LIST[@]/${MHA_DB_2}/}")
        MHA_REPL_LIST=("${MHA_REPL_LIST[@]/${MHA_CMASTER}/}")
fi
if [ $(mysql -h ${MHA_DB_3_IP} -P ${MHA_DB_3_PORT} -u${MHA_DB_ADMIN_ID} -p${MHA_DB_ADMIN_PW} -e "show slave status\G" | grep "Waiting for master to send event" | wc -l) -eq 1 ]; then
        MHA_CMASTER_IP=$(mysql -h ${MHA_DB_3_IP} -P ${MHA_DB_3_PORT} -u${MHA_DB_ADMIN_ID} -p${MHA_DB_ADMIN_PW} -e "show slave status\G" | grep Master_Host | awk -F": " '{print $2}')
        MHA_CMASTER_PORT=$(mysql -h ${MHA_DB_3_IP} -P ${MHA_DB_3_PORT} -u${MHA_DB_ADMIN_ID} -p${MHA_DB_ADMIN_PW} -e "show slave status\G" | grep Master_Port | awk -F": " '{print $2}')
        MHA_CMASTER=${MHA_CMASTER_IP}:${MHA_CMASTER_PORT}
        MHA_REPL_LIST=("${MHA_REPL_LIST[@]/${MHA_DB_3}/}")
        MHA_REPL_LIST=("${MHA_REPL_LIST[@]/${MHA_CMASTER}/}")
fi
if [ $(mysql -h ${MHA_DB_4_IP} -P ${MHA_DB_4_PORT} -u${MHA_DB_ADMIN_ID} -p${MHA_DB_ADMIN_PW} -e "show slave status\G" | grep "Waiting for master to send event" | wc -l) -eq 1 ]; then
        MHA_CMASTER_IP=$(mysql -h ${MHA_DB_4_IP} -P ${MHA_DB_4_PORT} -u${MHA_DB_ADMIN_ID} -p${MHA_DB_ADMIN_PW} -e "show slave status\G" | grep Master_Host | awk -F": " '{print $2}')
        MHA_CMASTER_PORT=$(mysql -h ${MHA_DB_4_IP} -P ${MHA_DB_4_PORT} -u${MHA_DB_ADMIN_ID} -p${MHA_DB_ADMIN_PW} -e "show slave status\G" | grep Master_Port | awk -F": " '{print $2}')
        MHA_CMASTER=${MHA_CMASTER_IP}:${MHA_CMASTER_PORT}
        MHA_REPL_LIST=("${MHA_REPL_LIST[@]/${MHA_DB_4}/}")
        MHA_REPL_LIST=("${MHA_REPL_LIST[@]/${MHA_CMASTER}/}")
fi

#Check the presence of Master
if [ -z ${MHA_CMASTER_IP} ]; then
        echo "### There was no master. So, ${MHA_DB_1} is now master!"
        USER_C=$(mysql -h ${MHA_DB_1_IP} -P ${MHA_DB_1_PORT} -u${MHA_DB_ADMIN_ID} -p${MHA_DB_ADMIN_PW} -e "select user from mysql.user where user='${MHA_DB_REPL_ID}'" | wc -l)
        if [ ${USER_C} -eq 0 ]; then
                mysql -h ${MHA_DB_1_IP} -P ${MHA_DB_1_PORT} -u${MHA_DB_ADMIN_ID} -p${MHA_DB_ADMIN_PW} -e "CREATE USER '${MHA_DB_REPL_ID}'@'%' IDENTIFIED BY '${MHA_DB_REPL_PW}';GRANT REPLICATION SLAVE ON *.* TO '${MHA_DB_REPL_ID}'@'%';flush privileges;"
        fi
        mysql -h ${MHA_DB_1_IP} -P ${MHA_DB_1_PORT} -u${MHA_DB_ADMIN_ID} -p${MHA_DB_ADMIN_PW} -e "SET GLOBAL read_only = 0;UNLOCK TABLES;STOP slave;RESET slave;"
        MHA_CMASTER_IP=${MHA_DB_1_IP}
        MHA_CMASTER_PORT=${MHA_DB_1_PORT}
        MHA_CMASTER=${MHA_CMASTER_IP}:${MHA_CMASTER_PORT}
        MHA_REPL_LIST=("${MHA_REPL_LIST[@]/${MHA_CMASTER}/}")
fi
echo "### Current Master is : ${MHA_CMASTER}"
echo "### Need Work List : ${MHA_REPL_LIST[@]}"
echo "### Checking Current Master and Slave Status [OK]"

#Deploy HAPROXY
if [ ${MHA_CMASTER_IP}${MHA_CMASTER_PORT} = ${MHA_DB_1_IP}${MHA_DB_1_PORT} ]; then
	/bin/bash /etc/mha_script/change_proxy1.sh
else
	/bin/bash /etc/mha_script/change_proxy2.sh
fi

#Dump from master
echo "### Dumping current Master's Databases. (${MHA_REPL_DB_1} ${MHA_REPL_DB_2} ${MHA_REPL_DB_3})"
mysqldump --single-transaction --routines --triggers --databases ${MHA_REPL_DB_1} ${MHA_REPL_DB_2} ${MHA_REPL_DB_3} -h ${MHA_CMASTER_IP} -P ${MHA_CMASTER_PORT} -u${MHA_DB_ADMIN_ID} -p${MHA_DB_ADMIN_PW} > /tmp/master_dump.db
echo "### Dumping current Master's Databases. (${MHA_REPL_DB_1} ${MHA_REPL_DB_2} ${MHA_REPL_DB_3}) [OK]"

echo "### Restart HAproxy"


#Get position from master
echo "### Getting Current Log_file and Log_pos from Master"
T_STRING=$(mysql -h ${MHA_CMASTER_IP} -P ${MHA_CMASTER_PORT} -u${MHA_DB_ADMIN_ID} -p${MHA_DB_ADMIN_PW} -e "show master status\G" | egrep '(File|Position)')
MHA_MASTER_LOG_FILE=$(echo ${T_STRING} | awk '{print $2}')
MHA_MASTER_LOG_POS=$(echo ${T_STRING} | awk '{print $4}')
echo "### Getting Current Log_file and Log_pos from Master [OK]"

#Start Slaves
echo "### Start slaves"
for REPL_TASK in ${MHA_REPL_LIST[@]}
do
        echo "### ${REPL_TASK} is going to slave"
        MHA_REPL_IP=$(echo ${REPL_TASK} | awk -F: '{print $1}')
        MHA_REPL_PORT=$(echo ${REPL_TASK} | awk -F: '{print $2}')
        mysql -h ${MHA_REPL_IP} -P ${MHA_REPL_PORT} -u${MHA_DB_ADMIN_ID} -p${MHA_DB_ADMIN_PW} -e "SET GLOBAL read_only = 0;UNLOCK TABLES;STOP slave;RESET slave;"
        USER_C=$(mysql -h ${MHA_REPL_IP} -P ${MHA_REPL_PORT} -u${MHA_DB_ADMIN_ID} -p${MHA_DB_ADMIN_PW} -e "select user from mysql.user where user='${MHA_DB_REPL_ID}'" | wc -l)
        if [ ${USER_C} -eq 0 ]; then
                mysql -h ${MHA_REPL_IP} -P ${MHA_REPL_PORT} -u${MHA_DB_ADMIN_ID} -p${MHA_DB_ADMIN_PW} -e "CREATE USER '${MHA_DB_REPL_ID}'@'%' IDENTIFIED BY '${MHA_DB_REPL_PW}';GRANT REPLICATION SLAVE ON *.* TO '${MHA_DB_REPL_ID}'@'%';flush privileges;"
        fi
        mysql -h ${MHA_REPL_IP} -P ${MHA_REPL_PORT} -u${MHA_DB_ADMIN_ID} -p${MHA_DB_ADMIN_PW} < /tmp/master_dump.db
        mysql -h ${MHA_REPL_IP} -P ${MHA_REPL_PORT} -u${MHA_DB_ADMIN_ID} -p${MHA_DB_ADMIN_PW} -e "CHANGE MASTER TO MASTER_HOST='${MHA_CMASTER_IP}', MASTER_PORT=${MHA_CMASTER_PORT}, MASTER_USER='${MHA_DB_REPL_ID}', MASTER_PASSWORD='${MHA_DB_REPL_PW}', MASTER_LOG_FILE='${MHA_MASTER_LOG_FILE}', MASTER_LOG_POS=${MHA_MASTER_LOG_POS};START SLAVE; "
        echo "### ${REPL_TASK} is now slave"
        mysql -h ${MHA_REPL_IP} -P ${MHA_REPL_PORT} -u${MHA_DB_ADMIN_ID} -p${MHA_DB_ADMIN_PW} -e "FLUSH TABLES WITH READ LOCK;SET GLOBAL read_only = 1;"
done
echo "### Start slaves [OK]"


#RUN SSHD and cron
systemd-tmpfiles --create
/usr/sbin/sshd
crontab /etc/cron.d/cron
cron

# Replace cnf
sed -i "s/\${MHA_DB_ADMIN_ID}/${MHA_DB_ADMIN_ID}/" /etc/mha.cnf
sed -i "s/\${MHA_DB_ADMIN_PW}/${MHA_DB_ADMIN_PW}/" /etc/mha.cnf
sed -i "s/\${MHA_DB_REPL_ID}/${MHA_DB_REPL_ID}/" /etc/mha.cnf
sed -i "s/\${MHA_DB_REPL_PW}/${MHA_DB_REPL_PW}/" /etc/mha.cnf
sed -i "s/\${MHA_DB_1_IP}/${MHA_DB_1_IP}/" /etc/mha.cnf
sed -i "s/\${MHA_DB_1_PORT}/${MHA_DB_1_PORT}/" /etc/mha.cnf
sed -i "s/\${MHA_DB_1_SSH_PORT}/${MHA_DB_1_SSH_PORT}/" /etc/mha.cnf
sed -i "s/\${MHA_DB_2_IP}/${MHA_DB_2_IP}/" /etc/mha.cnf
sed -i "s/\${MHA_DB_2_PORT}/${MHA_DB_2_PORT}/" /etc/mha.cnf
sed -i "s/\${MHA_DB_2_SSH_PORT}/${MHA_DB_2_SSH_PORT}/" /etc/mha.cnf
sed -i "s/\${MHA_DB_3_IP}/${MHA_DB_3_IP}/" /etc/mha.cnf
sed -i "s/\${MHA_DB_3_PORT}/${MHA_DB_3_PORT}/" /etc/mha.cnf
sed -i "s/\${MHA_DB_3_SSH_PORT}/${MHA_DB_3_SSH_PORT}/" /etc/mha.cnf
sed -i "s/\${MHA_DB_4_IP}/${MHA_DB_4_IP}/" /etc/mha.cnf
sed -i "s/\${MHA_DB_4_PORT}/${MHA_DB_4_PORT}/" /etc/mha.cnf
sed -i "s/\${MHA_DB_4_SSH_PORT}/${MHA_DB_4_SSH_PORT}/" /etc/mha.cnf
sed -i "s/\${MHA_DB_1_IP}/${MHA_DB_1_IP}/" /etc/mha_script/master_ip_failover_script
sed -i "s/\${MHA_DB_1_PORT}/${MHA_DB_1_PORT}/" /etc/mha_script/master_ip_failover_script
sed -i "s/\${MHA_DB_2_IP}/${MHA_DB_2_IP}/" /etc/mha_script/master_ip_failover_script
sed -i "s/\${MHA_DB_2_PORT}/${MHA_DB_2_PORT}/" /etc/mha_script/master_ip_failover_script
sed -i "s,\${MHA_HAPROXY_DCOS_NAME},${MHA_HAPROXY_DCOS_NAME}," /etc/mha_script/change_proxy1.sh
sed -i "s/\${MHA_DB_1_IP}/${MHA_DB_1_IP}/" /etc/mha_script/master_ip_online_change_script
sed -i "s/\${MHA_DB_2_IP}/${MHA_DB_2_IP}/" /etc/mha_script/master_ip_online_change_script
sed -i "s,\${MHA_HAPROXY_DCOS_NAME},${MHA_HAPROXY_DCOS_NAME}," /etc/mha_script/change_proxy2.sh

echo "### Starting MHA Manager"
mkdir -p /var/log/masterha
touch /var/log/masterha/MHA.log
masterha_manager --conf=/etc/mha.cnf &
tail -f /var/log/masterha/MHA.log

