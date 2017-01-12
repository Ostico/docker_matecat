#!/bin/bash

source /tmp/create_mysql_admin_user.sh

echo "Executing: mysqld_safe --defaults-file=/etc/mysql/my.cnf --user=mysql --plugin-dir=/usr/lib/mysql/plugin"
mysqld_safe --defaults-file=/etc/mysql/my.cnf --user=mysql --plugin-dir=/usr/lib/mysql/plugin &

while true; do
#    echo date " => Waiting for an infinite. More or less..."
    sleep 5
done
