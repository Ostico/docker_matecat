#!/bin/bash

echo "Copy configuration file to config dir."
cp /tmp/proxysql.cnf /etc/proxysql.cnf

echo "Kill auto started instance if present."
/etc/init.d/proxysql stop

echo "Clean the database rules"
rm -rf /var/lib/proxysql/*

echo "Executing: ProxySQL"
proxysql -f --idle-threads -c /etc/proxysql.cnf -D /var/lib/proxysql