#!/usr/bin/env bash

# MySQL
RET=1
while [[ RET -ne 0 ]]; do
  echo "=> Waiting for confirmation of MySQL service startup"
  sleep 5
  /usr/bin/mysql -uadmin -padmin -e "status" -h mysql-master > /dev/null 2>&1
  RET=$?
done

# set working dir
cd "${MATECAT_HOME}" || exit 1

# MateCat
MATECAT_VERSION=$(grep -F '=' ./inc/version.ini | awk '{print $3}')
[[ ! -f './inc/config.ini' ]] && cp /tmp/config.ini ./inc/
[[ ! -f './nodejs/config.ini' ]] && cp /tmp/node_config.ini ./nodejs/config.ini
[[ ! -f './inc/oauth_config.ini' ]] && cp /tmp/oauth_config.ini ./inc/
[[ ! -f './inc/Error_Mail_List.ini' ]] && cp /tmp/Error_Mail_List.ini ./inc/
[[ ! -f './inc/task_manager_config.ini' ]] && cp /tmp/task_manager_config.ini ./inc/

sed -ri -e "s/X.X.X/${MATECAT_VERSION}/g" ./inc/config.ini
# shellcheck disable=SC2153
sed -ri -e "s/_SMTP_HOST_/${SMTP_HOST}/g" ./inc/config.ini
sed -ri -e "s/_SMTP_HOST_/${SMTP_HOST}/g" ./inc/Error_Mail_List.ini

if [[ -n "${SMTP_PORT}" ]]; then
  sed -ri -e "s/SMTP_PORT = 25/SMTP_PORT = ${SMTP_PORT}/g" ./inc/config.ini
  sed -ri -e "s/Port = 25/Port = ${SMTP_PORT}/g" ./inc/Error_Mail_List.ini
  printf "Changed SMTP PORT address to: %s \n\n" "${SMTP_PORT}"
fi

if [[ -n "${FILTERS_ADDRESS}" ]]; then
  sed -ri -e "s%https:\/\/translated-matecat-filters-v1.p.mashape.com%${FILTERS_ADDRESS}%g" ./inc/config.ini
  printf "Changed filter address to: %s \n\n" "${FILTERS_ADDRESS}"
fi

# debug, configuration
cat ./inc/config.ini

php -r "readfile('https://getcomposer.org/installer');" | php
php "${MATECAT_HOME}"/composer.phar install

if ! type yarn 1>&2 2>/dev/null; then
  echo "Installing Yarn"
  npm install -g yarn
  echo "Installing sass@^1.77"
  npm install -g sass@^1.77
fi

echo "Refresh packages:"
rm -rf ./node_modules
yarn install
yarn build:dev

pushd ./nodejs || exit 1
sed -ri -e "s/localhost/amq/" server.js
echo "Refresh packages:"
rm -rf ./node_modules
npm install
node server.js &
popd || exit 1

### PLUGINS
bash /tmp/run_plugin_js_build.sh

chown -R "${USER_OWNER}" ./inc
chown -R "${USER_OWNER}" ./lib
chown -R "${USER_OWNER}" ./public
chown -R "${USER_OWNER}" ./support_scripts
chown -R "${USER_OWNER}" ./plugins
chown "${USER_OWNER}" ./router.php

## Apache/PHP Configurations
# Prepare PHP INI
sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" /etc/php/7.4/apache2/php.ini
sed -ri -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php/7.4/apache2/php.ini
sed -ri -e "s/^memory_limit.*/memory_limit = ${PHP_MAX_MEMORY}/" /etc/php/7.4/apache2/php.ini
sed -ri -e "s/^short_open_tag.*/short_open_tag = On/" /etc/php/7.4/apache2/php.ini

# Configure XDebug ( if needed )
if [[ -n "${XDEBUG_CONFIG}" ]]; then
  XDEBUG='
zend_extension=xdebug.so
xdebug.remote_enable=1
xdebug.remote_autostart=1
xdebug.remote_host="'${XDEBUG_CONFIG}'"
xdebug.remote_port=9000
xdebug.idekey="PHPSTORM"
'
  printf "%s\n\n" "${XDEBUG}" | tee >/etc/php/7.4/mods-available/xdebug.ini
fi
## Apache/PHP Configurations

########### BOOT ANALYSIS
pushd ./daemons || exit 1
/bin/bash restartAnalysis.sh
popd || exit 1

echo "Starting Apache..."
/etc/init.d/apache2 restart
echo "Apache Started"

while true; do
  #    echo date " => Waiting for an infinite. More or less..."
  sleep 5
done
