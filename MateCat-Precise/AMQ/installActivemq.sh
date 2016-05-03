#!/bin/bash
echo "Configuring ActiveMq\n"

if [[ ! -z "${ADM_ACCOUNT}" ]]; then
    mysqladmin -uroot shutdown
    return 0
fi

/etc/init.d/activemq create /etc/default/activemq

chown root:nogroup /etc/default/activemq

chmod 600 /etc/default/activemq

sed -i 's/managementContext createConnector="false"/managementContext createConnector="true"/g' /opt/activemq/conf/activemq.xml

ln -s /etc/init.d/activemq /usr/bin/activemq

/etc/init.d/activemq start

RET=1
while [[ RET -ne 0 ]]; do
    # echo "=> Waiting an infinite loop ..."
    sleep 5
done
