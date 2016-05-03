FROM ubuntu:trusty

RUN apt-get update
RUN apt-get -y --fix-missing install ssh-client vim locate iputils-ping monit git curl wget net-tools \
    apache2 php5 php5-json php5-curl php5-xdebug php5-mysql mysql-client openssh-server psmisc screen dstat \
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
