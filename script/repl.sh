#!/bin/bash
. /env.sh
MHA_DB_1="${MHA_DB_1_IP}:${MHA_DB_1_PORT}"
MHA_DB_2="${MHA_DB_2_IP}:${MHA_DB_2_PORT}"
MHA_DB_3="${MHA_DB_3_IP}:${MHA_DB_3_PORT}"
MHA_DB_4="${MHA_DB_4_IP}:${MHA_DB_4_PORT}"
MHA_REPL_LIST=(${MHA_DB_1} ${MHA_DB_2} ${MHA_DB_3} ${MHA_DB_4})
MHA_CMASTER_IP=""
MHA_CMASTER_PORT=""
MHA_CMASTER=""
echo "### Checking ENV [OK]"

echo "### Checking PS"
PS_COUNTER=0
for i in $(seq 1 3)
do
        CHECK_PS=$(ps -ef | egrep '(defunct|master_ip_failover_script)' | wc -l)
        if [ ${CHECK_PS} -eq 1 ]; then
                PS_COUNTER=$((PS_COUNTER+1))
        fi
        sleep 0.5
done

if [ ${PS_COUNTER} -ne 3 ]; then
        echo "###Master is now failovering. Stop CRON script."
        exit 1
fi
echo "### Checking PS [OK]"


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
if [ $? -ne 0 ]; then
	echo "### [Warn] Dump from master fail...."
	exit 1
fi
echo "### Dumping current Master's Databases. (${MHA_REPL_DB_1} ${MHA_REPL_DB_2} ${MHA_REPL_DB_3}) [OK]"

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

echo "### Check MHA manager Stats"
MHA_STATS=$(ps -ef | grep /usr/bin/masterha_manager | wc -l)
if [ ${MHA_STATS} -ne 2 ];then
	masterha_manager --conf=/etc/mha.cnf
else
	echo "MHA_Status_is...[OK]"
fi

echo "### Cleanup dump file"
rm -f /tmp/master_dump.db
