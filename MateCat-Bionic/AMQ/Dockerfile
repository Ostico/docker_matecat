FROM ostico/bionic-base:latest

RUN apt-get update
RUN apt-get -y full-upgrade

RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

ENV JAVA_OPTS '-Xmx256M'
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -snvf /bin/true /sbin/initctl
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:openjdk-r/ppa && \
    apt-get update
RUN apt-get install -y  openjdk-8-jre

RUN cd /tmp/
RUN wget http://archive.apache.org/dist/activemq/5.15.10/apache-activemq-5.15.10-bin.tar.gz
RUN tar xzf apache-activemq-5.15.10-bin.tar.gz && rm apache-activemq-5.15.10-bin.tar.gz
RUN mv apache-activemq-5.15.10 /opt
RUN ln -sf /opt/apache-activemq-5.15.10/ /opt/activemq
RUN adduser -system activemq
RUN sed -i "s#activemq:/bin/false#activemq:/bin/bash#g" /etc/passwd
RUN chown -R activemq: /opt/apache-activemq-5.15.10/
RUN ln -sf /opt/activemq/bin/activemq /etc/init.d/


RUN /etc/init.d/activemq create /etc/default/activemq
RUN chown root:nogroup /etc/default/activemq
RUN chmod 600 /etc/default/activemq

RUN sed -i 's/managementContext createConnector="false"/managementContext createConnector="true"/g' /opt/activemq/conf/activemq.xml
RUN ln -s /etc/init.d/activemq /usr/bin/activemq

CMD ["activemq", "console"]
