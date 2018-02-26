#!/bin/bash

echo "Copy configuration file to config dir."
cp /tmp/proxysql.cnf /etc/proxysql.cnf

echo "Kill auto started instance if present."
/etc/init.d/proxysql stop

echo "Clean the database rules"
rm -rf /var/lib/proxysql/*

echo "Executing: ProxySQL"
proxysql -c /etc/proxysql.cnf -D /var/lib/proxysql

while true; do
#    echo date " => Waiting for an infinite. More or less..."
    sleep 5
done