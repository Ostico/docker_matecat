#!/usr/bin/env bash

# SSHD server
/usr/sbin/sshd

# Monit
/etc/init.d/monit start

# MySQL
RET=1
while [[ RET -ne 0 ]]; do
    echo "=> Waiting for confirmation of MySQL service startup"
    sleep 5
    /usr/bin/mysql -uadmin -padmin -e "status" -h mysql # > /dev/null 2>&1
    RET=$?
done

# set working dir
cd ${MATECAT_HOME}

MATECAT_EXISTS=$(mysql -uadmin -padmin -h mysql -e "show databases like 'matecat%'")
if [[ -z "${MATECAT_EXISTS}" ]]; then
    # MySql MateCat
    # Creating schema and fill some data
    echo "Executing: /usr/bin/mysql -uadmin -padmin -h mysql < ./lib/Model/matecat.sql"
    /usr/bin/mysql -uadmin -padmin -h mysql < ./lib/Model/matecat.sql
fi


# Prepare PHP INI
sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" /etc/php5/apache2/php.ini
sed -ri -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php5/apache2/php.ini
sed -ri -e "s/^memory_limit.*/memory_limit = ${PHP_MAX_MEMORY}/" /etc/php5/apache2/php.ini
sed -ri -e "s/^short_open_tag.*/short_open_tag = On/" /etc/php5/apache2/php.ini

# get the container IP
ContainerIP=`ifconfig  | grep 'eth0' -1 | grep 'inet' | cut -d: -f2 | awk '{ print $1}'`
echo "Container IP: " ${ContainerIP}

# Configure XDebug ( if needed )
XDEBUG='zend_extension='$(find /usr/lib/php5/ -name xdebug.so)'
xdebug.remote_enable=1
xdebug.remote_autostart=1
xdebug.remote_host="'${ContainerIP}'"
xdebug.remote_port=9000
xdebug.idekey="storm"
'
printf "${XDEBUG}" > /etc/php5/conf.d/xdebug.ini

apache2ctl stop
echo "Apache Stopped"

# MateCat
MATECAT_VERSION=$(fgrep '=' ./inc/version.ini | awk '{print $3}')
cp /tmp/config.ini ./inc/
cp /tmp/oauth_config.ini ./inc/
cp /tmp/task_manager_config.ini ./daemons/

sed -ri -e "s/X.X.X/${MATECAT_VERSION}/g" ./inc/config.ini

# debug, configuration
printf "`cat ./inc/config.ini`"

pushd ./support_scripts/grunt

    type_msg=$( type grunt >/dev/null )

    if ! type grunt >/dev/null; then
        rm -rf ./node_modules
        echo "Installing grunt"
        npm install -g
        npm install -g grunt-cli
        npm install
        npm install grunt-cli
    fi

    grunt development
popd

pushd ./nodejs
    if [[ -z "node_modules" ]]; then
        # NodeJs install sse-channel events
        npm install
        sed -ri -e "s/localhost/amq/" server.js
    fi
popd

chown -R ${USER_OWNER} ./inc
chown -R ${USER_OWNER} ./lib
chown -R ${USER_OWNER} ./public
chown -R ${USER_OWNER} ./support_scripts
chown ${USER_OWNER} ./index.php


########### BOOT ANALYSIS
pushd ./lib/Utils/Analysis
/bin/bash restartAnalysis.sh
popd

echo "Starting Apache..."
/etc/init.d/apache2 restart

while true; do
#    echo date " => Waiting for an infinite. More or less..."
    sleep 5
done