FROM ostico/trusty-base:latest

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

# NodeJs
COPY ./node-install.sh /tmp/node-install.sh
RUN chmod +x /tmp/node-install.sh
RUN /tmp/node-install.sh
RUN rm /tmp/node-install.sh

# Monit
COPY monitrc /etc/monit/monitrc

# Apache
RUN mkdir /var/log/apache2/matecat/
RUN rm -rf /etc/apache2/sites-available/default
RUN rm -rf /etc/apache2/sites-enabled/*
RUN userdel www-data
RUN groupadd www-data
RUN useradd -ms /bin/bash -g www-data www-data

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

# Start app_configslication
COPY environment_setup.sh /tmp/environment_setup.sh
RUN chmod +x /tmp/environment_setup.sh

COPY run.sh /tmp/run.sh
RUN chmod +x /tmp/run.sh

WORKDIR "/var/www/matecat"
CMD ["/tmp/run.sh"]
