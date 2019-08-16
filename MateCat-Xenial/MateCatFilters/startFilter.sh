#!/bin/bash

if [ ! -d "/var/www/MateCat-Filters/" ]; then

    FILTER_BUILD=$(ls /tmp | grep -E "^filters-[0-9\.]+.jar$")
    if [ ! -z "${FILTER_BUILD}" ]; then
        mkdir -p /var/www/MateCat-Filters/
        mv /tmp/${FILTER_BUILD} /var/www/MateCat-Filters/
    else
        echo "No binary found. Build okapi"
        git clone https://bitbucket.org/okapiframework/okapi.git /var/www/okapi
        cd /var/www/okapi/
        git checkout `curl -s https://raw.githubusercontent.com/matecat/MateCat-Filters/master/pom.xml | grep -oP '(?<=<okapi.commit>).*?(?=</okapi.commit>)'`
        mvn clean install -DskipTests=true

        echo "clone the repo"
        git clone https://github.com/matecat/MateCat-Filters.git

        echo "Setting configurations"
        cd /var/www/okapi/MateCat-Filters/filters/src/main/resources
        mv config.sample.properties config.properties

        echo "build matecat filters layer"
        cd /var/www/okapi/MateCat-Filters/filters
        mvn clean package -DskipTests=true

        echo "copy artifact"
        mkdir -p /var/www/MateCat-Filters/
        cp -a /var/www/okapi/MateCat-Filters/filters/target/* /var/www/MateCat-Filters/

        echo "Purge Maven"
        cd ..
        mvn dependency:purge-local-repository -DactTransitively=false -DreResolve=false
        rm -rf /var/www/okapi
    fi

fi

echo "Starting Filter\n"
cd /var/www/MateCat-Filters/

FILTER_BUILD=$(ls | grep -E "^filters-[0-9\.]+.jar$")
java -cp ".:${FILTER_BUILD}" com.matecat.converter.Main

RET=1
while [[ RET -ne 0 ]]; do
    # echo "=> Waiting an infinite loop ..."
    sleep 5
done