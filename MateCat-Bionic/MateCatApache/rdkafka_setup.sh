#!/usr/bin/env bash

RDKAFKA_MODULE_DIR=`pecl install rdkafka | grep 'Zend Module Api No:' | awk '{print $5}'`

printf "**** Installing Pecl module rdkafka into /usr/lib/php/${RDKAFKA_MODULE_DIR}\n\n"

ln -s /usr/lib/php/${RDKAFKA_MODULE_DIR}/rdkafka.so /usr/lib/php/5.6/rdkafka.so

printf "zend_extension=/usr/lib/php/5.6/rdkafka.so\n\n"
printf "zend_extension=/usr/lib/php/5.6/rdkafka.so" > /etc/php/5.6/mods-available/rdkafka.ini

phpenmod rdkafka