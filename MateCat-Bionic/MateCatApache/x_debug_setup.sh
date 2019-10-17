#!/usr/bin/env bash

pushd /tmp
wget https://xdebug.org/files/xdebug-2.5.5.tgz
tar -xvzf xdebug-2.5.5.tgz
cd xdebug-2.5.5
XDEBUG_MODULE_DIR=`phpize | grep 'Zend Module Api No:' | awk '{print $5}'`
./configure
make
cp modules/xdebug.so /usr/lib/php/${XDEBUG_MODULE_DIR}
ln -s /usr/lib/php/${XDEBUG_MODULE_DIR}/xdebug.so /usr/lib/php/5.6/xdebug.so

phpenmod xdebug