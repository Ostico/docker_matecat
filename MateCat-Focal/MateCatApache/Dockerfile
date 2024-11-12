FROM ostico/matecat-focal-base-image:latest

ENV NODE_RELEASE="20.x"
ENV PHPDIR="/etc/php/7.4"

RUN export DEBIAN_FRONTEND=noninteractive
RUN ln -fs /usr/share/zoneinfo/Europe/Rome /etc/localtime

RUN apt-get update
RUN apt-get -y full-upgrade

RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

RUN mkdir -p /etc/apt/keyrings nodejs \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_RELEASE}.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get -y --fix-missing install apache2 apache2-dev libapache2-mod-php \
            php php-xdebug php-json php-xml php-curl php-mysql php-mbstring php-dev php-redis php-zip php-gd mysql-client libzip-dev \
            certbot python3-certbot-apache redis-tools nodejs \
    && echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Prepare the environment
ENV PHP_POST_MAX_SIZE 1024M
ENV PHP_UPLOAD_MAX_FILESIZE 1024M
ENV PHP_MAX_MEMORY 4096M

ENV SERVICES_DIR "/etc/init.d"
ENV USER_OWNER "www-data"
ENV MATECAT_HOME "/var/www/matecat"

COPY ./app_configs/config.ini /tmp/config.ini
COPY ./app_configs/node_config.ini /tmp/node_config.ini
COPY ./app_configs/Error_Mail_List.ini /tmp/Error_Mail_List.ini

# If you want to enable the login ssystem add your oauth_config.ini taken from Google
#COPY ./app_configs/oauth_config.ini /tmp/oauth_config.ini

COPY ./app_configs/task_manager_config.ini /tmp/task_manager_config.ini

# Apache
RUN mkdir /var/log/apache2/matecat/
RUN rm -rf /etc/apache2/sites-available/default
RUN rm -rf /etc/apache2/sites-enabled/*
RUN userdel www-data
RUN groupadd www-data
RUN useradd -ms /bin/bash -g www-data www-data

RUN sed -i 's/session.save_handler\s*=\s*files/session.save_handler = redis/' ${PHPDIR}/apache2/php.ini
RUN echo 'session.save_path = "tcp://redis:6379?database=15"' >> ${PHPDIR}/apache2/php.ini

## Enable MateCat site
COPY data/ /

RUN a2enmod rewrite filter deflate headers expires proxy_http ssl php7.4 proxy_balancer proxy_wstunnel slotmem_shm
RUN #phpenmod mcrypt

COPY run_plugin_js_build.sh /tmp/run_plugin_js_build.sh
COPY run.sh /tmp/run.sh
RUN chmod +x /tmp/run_plugin_js_build.sh
RUN chmod +x /tmp/run.sh

WORKDIR "/var/www/matecat"
CMD ["/tmp/run.sh"]
