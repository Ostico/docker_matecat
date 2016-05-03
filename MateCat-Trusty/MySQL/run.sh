#!/bin/bash

source /tmp/create_mysql_admin_user.sh

echo "Executing: mysqld_safe --defaults-file=/etc/mysql/my.cnf --user=mysql --plugin-dir=/usr/lib/mysql/plugin"
mysqld_safe --defaults-file=/etc/mysql/my.cnf --user=mysql --plugin-dir=/usr/lib/mysql/plugin
