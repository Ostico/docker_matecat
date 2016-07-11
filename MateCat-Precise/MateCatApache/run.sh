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

# Configure XDebug ( if needed )
if [[ -n "${XDEBUG_CONFIG}" ]]; then
    XDEBUG='zend_extension='$(find /usr/lib/php5/ -name xdebug.so)'
    xdebug.remote_enable=1
    xdebug.remote_autostart=1
    xdebug.remote_host="'${XDEBUG_CONFIG}'"
    xdebug.remote_port=9000
    xdebug.idekey="storm"'

    printf "${XDEBUG}\n\n"
    printf "${XDEBUG}" > /etc/php5/conf.d/xdebug.ini
fi

apache2ctl stop
echo "Apache Stopped"

# MateCat
MATECAT_VERSION=$(fgrep '=' ./inc/version.ini | awk '{print $3}')
cp /tmp/config.ini ./inc/
cp /tmp/node_config.ini ./nodejs/config.ini
cp /tmp/oauth_config.ini ./inc/
cp /tmp/Error_Mail_List.ini ./inc/
cp /tmp/task_manager_config.ini ./inc/

sed -ri -e "s/X.X.X/${MATECAT_VERSION}/g" ./inc/config.ini
sed -ri -e "s/_SMTP_HOST_/${SMTP_HOST}/g" ./inc/config.ini
sed -ri -e "s/_SMTP_HOST_/${SMTP_HOST}/g" ./inc/Error_Mail_List.ini

if [[ -n "${SMTP_PORT}" ]]; then
    sed -ri -e "s/SMTP_PORT = 25/SMTP_PORT = ${SMTP_PORT}/g" ./inc/config.ini
    sed -ri -e "s/Port = 25/Port = ${SMTP_PORT}/g" ./inc/Error_Mail_List.ini
    printf "Changed SMTP PORT address to: ${SMTP_PORT}\n\n"
fi

if [[ -n "${FILTERS_ADDRESS}" ]]; then
    sed -ri -e "s%https://translated-matecat-filters-v1.p.mashape.com%${FILTERS_ADDRESS}%g" ./inc/config.ini
    printf "Changed filter address to: ${FILTERS_ADDRESS}\n\n"
fi

# debug, configuration
echo "`cat ./inc/config.ini`"

php -r "readfile('https://getcomposer.org/installer');" | php
php ${MATECAT_HOME}/composer.phar install

pushd ./support_scripts/grunt

    type_msg=$( type grunt >/dev/null )

    if ! type grunt >/dev/null; then
        rm -rf ./node_modules
        echo "Installing grunt"
        npm install -g grunt-cli
    fi

    npm install
    grunt development

popd

pushd ./nodejs
    if [[ -z "node_modules" ]]; then
        # NodeJs install sse-channel events
        sed -ri -e "s/localhost/amq/" server.js
    fi
    npm install
    node server.js &
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
