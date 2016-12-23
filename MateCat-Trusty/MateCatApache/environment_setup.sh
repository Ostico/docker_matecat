#!/usr/bin/env bash

pushd /tmp
wget http://xdebug.org/files/xdebug-2.5.0.tgz
tar -xvzf xdebug-2.5.0.tgz
cd xdebug-2.5.0
XDEBUG_MODULE_DIR=`phpize | grep 'Zend Module Api No:' | awk '{print $5}'`
./configure
make
cp modules/xdebug.so /usr/lib/php5/${XDEBUG_MODULE_DIR}