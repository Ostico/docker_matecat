#!/bin/bash

rm /var/run/mysqld/mysqld.pid 2>/dev/null

echo "Initialize mysql: mysqld --initialize-insecure"
mysqld --initialize-insecure

echo "Executing: mysql --defaults-file=/etc/mysql/my.cnf --user=mysql --daemonize --plugin-dir=/usr/lib/mysql/plugin --pid-file=/var/run/mysqld/mysqld.pid"
mysqld --defaults-file=/etc/mysql/my.cnf --user=mysql --daemonize --plugin-dir=/usr/lib/mysql/plugin --pid-file=/var/run/mysqld/mysqld.pid

source /tmp/create_mysql_admin_user.sh

MATECAT_EXISTS=$(mysql -uadmin -padmin -h mysql-master -e "show databases like 'matecat%'")
if [[ -z "${MATECAT_EXISTS}" && "${_type_}" == "master" ]]; then

  # Get the master GTID
  mysql -uadmin -padmin -h mysql-master -e "CREATE DATABASE test;"
  mysql -uadmin -padmin -h mysql-master -e "DROP DATABASE test;"
  sleep 2

elif [[ -z "${MATECAT_EXISTS}" && "${_type_}" == "slave" ]]; then

  RET=1
  while [[ RET -ne 0 ]]; do

    echo "=> Waiting for confirmation of MySQL Master ready"
    MYSQL_MASTER_GTID=$(mysql -uadmin -padmin -h mysql-master -e "SHOW MASTER STATUS\G" | grep -i "Executed_Gtid_Set:" | awk '{print $2}')
    printf "*** MYSQL_MASTER_GTID: %s \n\n" "${MYSQL_MASTER_GTID}"

    if [[ -n "${MYSQL_MASTER_GTID}" ]]; then
      RET=0
    fi

  done

  #Set Replication
  echo "#Set Replication"
  mysql -uadmin -padmin -h mysql-slave -e "RESET MASTER"
  mysql -uadmin -padmin -h mysql-slave -e "STOP SLAVE; RESET SLAVE ALL;"
  mysql -uadmin -padmin -h mysql-slave -e "SET GLOBAL gtid_purged=\"${MYSQL_MASTER_GTID}\" ;"
  mysql -uadmin -padmin -h mysql-slave -e "CHANGE MASTER TO MASTER_HOST=\"mysql-master\", MASTER_USER=\"admin\", MASTER_PASSWORD=\"admin\", MASTER_AUTO_POSITION = 1; START SLAVE;"

  sleep 1
  SLAVE_STATUS=$(mysql -uadmin -padmin -h mysql-slave -e "SHOW SLAVE STATUS \G")
  printf "%s \n\n" "${SLAVE_STATUS}"
  sleep 5

  # MySql MateCat
  git clone https://github.com/matecat/MateCat.git /tmp/matecat

  # Creating schema and fill some data
  echo "Executing: /usr/bin/mysql -uadmin -padmin -h mysql-master < ./lib/Model/matecat.sql"
  /usr/bin/mysql -uadmin -padmin -h mysql-master </tmp/matecat/lib/Model/matecat.sql

  # clean
  rm -rf /tmp/matecat

fi

while true; do
  #    echo date " => Waiting for an infinite. More or less..."
  sleep 5
done
