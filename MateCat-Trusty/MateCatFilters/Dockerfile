FROM maven:3.3.3-jdk-8

RUN apt-get update
RUN apt-get install -y git

COPY startFilter.sh /tmp/startFilter.sh
RUN chmod +x /tmp/startFilter.sh
CMD ["/tmp/startFilter.sh"]
