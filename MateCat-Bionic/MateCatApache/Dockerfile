FROM ostico/bionic-base:latest

# Prepare the environment
ENV PHP_POST_MAX_SIZE 1024M
ENV PHP_UPLOAD_MAX_FILESIZE 1024M
ENV PHP_MAX_MEMORY 4096M

ENV SERVICES_DIR "/etc/init.d"
ENV USER_OWNER "www-data"
ENV MATECAT_HOME "/var/www/matecat"

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

RUN ln -fs /usr/share/zoneinfo/Europe/Rome /etc/localtime

RUN apt-get update && apt-get -y full-upgrade

RUN locale-gen en_US.UTF-8
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/apache2
RUN apt-get update && apt-get -y --fix-missing install \
    apache2 apache2-dev libapache2-mod-php5.6 \
#librdkafka1 librdkafka-dev \
    php5.6 php5.6-json php5.6-curl php5.6-xdebug php5.6-mysql php5.6-xml php5.6-mbstring php5.6-dev php5.6-mcrypt php5.6-redis php5.6-zip \
    mysql-client libzip-dev unzip \
    && echo "ServerName localhost" >> /etc/apache2/apache2.conf

COPY ./app_configs/config.ini /tmp/config.ini
COPY ./app_configs/node_config.ini /tmp/node_config.ini
COPY ./app_configs/Error_Mail_List.ini /tmp/Error_Mail_List.ini
COPY ./app_configs/oauth_config.ini /tmp/oauth_config.ini
COPY ./app_configs/task_manager_config.ini /tmp/task_manager_config.ini

# Apache
RUN mkdir /var/log/apache2/matecat/
RUN rm -rf /etc/apache2/sites-available/default
RUN rm -rf /etc/apache2/sites-enabled/*
RUN userdel www-data && groupadd www-data && useradd -ms /bin/bash -g www-data www-data

RUN sed -i 's/session.save_handler\s*=\s*files/session.save_handler = redis/' /etc/php/5.6/apache2/php.ini
RUN echo 'session.save_path = "tcp://redis:6379?database=15"' >> /etc/php/5.6/apache2/php.ini


## ENABLE Deployment utils ( apache follows symbolic links to DocumentRoot )
RUN git clone https://github.com/etsy/mod_realdoc.git
WORKDIR "/mod_realdoc"
RUN apxs2 -i -a -c mod_realdoc.c
WORKDIR "/"
RUN rm -rf ./mod_realdoc

## Enable MateCat site
COPY data/ /

RUN a2enmod rewrite filter deflate headers expires proxy_http ssl php5.6
RUN phpenmod mcrypt

# Set XDebug
COPY x_debug_setup.sh /tmp/x_debug_setup.sh
RUN chmod +x /tmp/x_debug_setup.sh
RUN /tmp/x_debug_setup.sh

# Set rdkafka
#COPY rdkafka_setup.sh /tmp/rdkafka_setup.sh
#RUN chmod +x /tmp/rdkafka_setup.sh
#RUN /tmp/rdkafka_setup.sh

# NodeJs
COPY ./node-install.sh /tmp/node-install.sh
RUN chmod +x /tmp/node-install.sh
RUN /tmp/node-install.sh
RUN rm /tmp/node-install.sh

COPY prepare.sh /tmp/prepare.sh
RUN chmod +x /tmp/prepare.sh

WORKDIR /var/www/matecat
RUN git clone https://github.com/matecat/MateCat.git .

RUN /tmp/prepare.sh

COPY run-matecat.sh /run-matecat.sh
RUN chmod +x /run-matecat.sh

COPY run-fast-analysis.sh /run-fast-analysis.sh
RUN chmod +x /run-fast-analysis.sh

COPY run-tm-analysis.sh /run-tm-analysis.sh
RUN chmod +x /run-tm-analysis.sh

RUN chown -R ${USER_OWNER} ./lib ./public ./support_scripts ./index.php
