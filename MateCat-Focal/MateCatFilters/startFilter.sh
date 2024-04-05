#!/bin/bash

printf "Starting Filter\n"
cd /var/www/MateCat-Filters/ || exit 1

# shellcheck disable=SC2010
FILTER_BUILD=$(ls | grep -E "^filters-[0-9\.]+.jar$")
java -cp ".:${FILTER_BUILD}" com.matecat.converter.Main