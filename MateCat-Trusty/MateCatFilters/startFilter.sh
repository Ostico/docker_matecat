#!/bin/bash

if [ ! -d "/var/www/MateCat-Filters/" ]; then
    echo "Build okapi"
    git clone https://bitbucket.org/okapiframework/okapi.git /var/www/okapi
    cd /var/www/okapi/
    git checkout matecat
    mvn clean install -DskipTests=true

    echo "build matecat filters layer"
    git clone https://github.com/matecat/MateCat-Filters.git
    cd /var/www/okapi/MateCat-Filters
    mvn clean package -DskipTests=true

    echo "Setting configurations"
    cd /var/www/okapi/MateCat-Filters/target
    cp ../src/main/resources/config.sample.properties config.properties
    mkdir -p /var/www/MateCat-Filters/
    cp -a /var/www/okapi/MateCat-Filters/target/* /var/www/MateCat-Filters/

    echo "Purge Maven"
    mvn dependency:purge-local-repository -DactTransitively=false -DreResolve=false
    rm -rf /var/www/okapi
fi

echo "Starting Filter\n"
cd /var/www/MateCat-Filters/

java -cp ".:filters-1.1.3.jar" com.matecat.converter.Main

RET=1
while [[ RET -ne 0 ]]; do
    # echo "=> Waiting an infinite loop ..."
    sleep 5
done
