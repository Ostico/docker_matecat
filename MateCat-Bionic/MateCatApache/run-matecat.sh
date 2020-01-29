#!/usr/bin/env bash

# MySQL
RET=1
while [[ RET -ne 0 ]]; do
    echo "=> Waiting for confirmation of MySQL service startup"
    /usr/bin/mysql -uadmin -padmin -e "status" -h mysql # > /dev/null 2>&1
    sleep 2
    RET=$?
done
echo "=> MySQL is available! OK"

# set working dir
cd ${MATECAT_HOME}

echo "=> Ensuring matecat schema exists"
# MySql MateCat
# Creating schema and fill some data
MATECAT_EXISTS=$(mysql -uadmin -padmin -h mysql -e "show databases like 'matecat%'")
if [[ -z "${MATECAT_EXISTS}" ]]; then
    echo "=> matecat schema does not exist, creating"
    echo "=> Executing: /usr/bin/mysql -uadmin -padmin -h mysql < ./lib/Model/matecat.sql"
    /usr/bin/mysql -uadmin -padmin -h mysql < ./lib/Model/matecat.sql
    SCHEMA_CREATE=$?
    if [[ SCHEMA_CREATE -ne 0 ]]; then
      echo "=> ERROR SCHEMA_CREATE=$SCHEMA_CREATE"
      exit
    fi
fi

# set configurations
MATECAT_VERSION=$(fgrep '=' ./inc/version.ini | awk '{print $3}')

sed -ri -e "s/^OAUTH_CLIENT_ID.*/OAUTH_CLIENT_ID = \"${OAUTH_CLIENT_ID}\"/g" ./inc/oauth_config.ini
sed -ri -e "s/^OAUTH_CLIENT_SECRET.*/OAUTH_CLIENT_SECRET = \"${OAUTH_CLIENT_SECRET}\"/g" ./inc/oauth_config.ini
sed -ri -e "s/^BUILD_NUMBER = .*/BUILD_NUMBER = \"${MATECAT_VERSION}\"/g" ./inc/config.ini
sed -ri -e "s/^SMTP_HOST = .*/SMTP_HOST = \"${SMTP_HOST}\"/g" ./inc/config.ini
sed -ri -e "s/^Host = .*/Host = \"${SMTP_HOST}\"/g" ./inc/Error_Mail_List.ini

if [[ -n "${SMTP_PORT}" ]]; then
    sed -ri -e "s/SMTP_PORT = .*/SMTP_PORT = ${SMTP_PORT}/g" ./inc/config.ini
    sed -ri -e "s/Port = .*/Port = ${SMTP_PORT}/g" ./inc/Error_Mail_List.ini
    printf "Changed SMTP PORT address to: ${SMTP_PORT}\n\n"
fi

if [[ -n "${FILTERS_ADDRESS}" ]]; then
    sed -ri -e "s|FILTERS_ADDRESS = .*|FILTERS_ADDRESS = \"${FILTERS_ADDRESS}\"|g" ./inc/config.ini
    printf "Changed filter address to: ${FILTERS_ADDRESS}\n\n"
fi

chown -R ${USER_OWNER} ./inc

## Aache/PHPConfigurations
# Prepare PHP INI
sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" /etc/php/5.6/apache2/php.ini
sed -ri -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php/5.6/apache2/php.ini
sed -ri -e "s/^memory_limit.*/memory_limit = ${PHP_MAX_MEMORY}/" /etc/php/5.6/apache2/php.ini
sed -ri -e "s/^short_open_tag.*/short_open_tag = On/" /etc/php/5.6/apache2/php.ini

# Configure XDebug ( if needed )
if [[ -n "${XDEBUG_CONFIG}" ]]; then
    XDEBUG='zend_extension='$(find /usr/lib/php/5.6/ -name xdebug.so)'
    xdebug.remote_enable=1
    xdebug.remote_autostart=1
    xdebug.remote_host="'${XDEBUG_CONFIG}'"
    xdebug.remote_port=9000
    xdebug.idekey="PHPSTORM"'

    printf "${XDEBUG}\n\n"
    printf "${XDEBUG}" > /etc/php/5.6/mods-available/xdebug.ini
fi

pushd ./nodejs
node server.js &
popd

/usr/sbin/apache2ctl -DFOREGROUND
