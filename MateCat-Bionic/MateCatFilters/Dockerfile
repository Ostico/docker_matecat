FROM ostico/bionic-base:latest

RUN apt-get update
RUN apt-get -y full-upgrade

RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

RUN apt-get update
RUN apt-get install -y git software-properties-common && \
    add-apt-repository -y ppa:openjdk-r/ppa && \
    apt-get update
RUN apt-get install -y  openjdk-8-jre

COPY data /

COPY startFilter.sh /tmp/startFilter.sh
RUN chmod +x /tmp/startFilter.sh
CMD ["/tmp/startFilter.sh"]
