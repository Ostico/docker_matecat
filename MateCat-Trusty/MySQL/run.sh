#!/bin/bash

/usr/sbin/mysqld --defaults-file=/etc/mysql/my.cnf --user=mysql --initialize-insecure

pushd /var/lib/mysql
mkdir -p ./binlog
chown mysql:mysql ./binlog
find . -type d | xargs chmod 770
find . -type f | xargs chmod 660
popd

source /tmp/create_mysql_admin_user.sh

echo "Executing: mysqld_safe --defaults-file=/etc/mysql/my.cnf --user=mysql --plugin-dir=/usr/lib/mysql/plugin"
mysqld_safe --defaults-file=/etc/mysql/my.cnf --user=mysql --plugin-dir=/usr/lib/mysql/plugin &

while true; do
#    echo date " => Waiting for an infinite. More or less..."
    sleep 5
done
