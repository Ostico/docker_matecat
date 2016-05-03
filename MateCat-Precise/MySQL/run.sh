#!/bin/bash

source /tmp/create_mysql_admin_user.sh

echo "Executing: /usr/bin/mysqld_safe --defaults-file=/etc/mysql/my.cnf --user=mysql --sql-mode=''"
/usr/bin/mysqld_safe --defaults-file=/etc/mysql/my.cnf --user=mysql --sql-mode=''
