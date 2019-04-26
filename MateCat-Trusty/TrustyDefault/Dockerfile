FROM ubuntu:trusty

RUN apt-get update
RUN apt-get install -y software-properties-common
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/apache2
RUN apt-get update
RUN apt-get -y --fix-missing install ssh-client vim locate iputils-ping monit git curl wget net-tools tree \
    apache2 apache2-dev libapache2-mod-php5.6 \
    php5.6 php5.6-json php5.6-curl php5.6-xdebug php5.6-mysql php5.6-xml php5.6-dev php5.6-mcrypt php5.6-redis \
    mysql-client openssh-server psmisc screen dstat \
    traceroute whois libaio1 perl perl-base perl-modules \
    && echo "ServerName localhost" >> /etc/apache2/apache2.conf

RUN apt-get -y upgrade

# SSH Server
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
