#!/bin/bash
printf "Configuring ActiveMq\n"

# Not configured, configure AMQ
if [ -d "/etc/default/activemq" ]; then

  service activemq create /etc/default/activemq

  chown root:nogroup /etc/default/activemq

  chmod 600 /etc/default/activemq

  sed -i 's/managementContext createConnector="false"/managementContext createConnector="true"/g' /opt/activemq/conf/activemq.xml

  ln -s /etc/init.d/activemq /usr/bin/activemq

fi

service activemq start

RET=1
while [[ RET -ne 0 ]]; do
  # echo "=> Waiting an infinite loop ..."
  sleep 5
done
