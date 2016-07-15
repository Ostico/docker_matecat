# Capistrano image to be used with https://github.com/marmelab/make-docker-command
FROM ostico/trusty-base:latest

ENV HOME /root

RUN apt-get install -y software-properties-common
RUN apt-add-repository ppa:brightbox/ruby-ng

# install deps
RUN apt-get update && \
    apt-get install -y ruby2.0 ruby2.0-dev make ssh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# install capistrano
RUN gem install --no-rdoc --no-ri capistrano -v 3.5.0

# install deps
RUN gem install --no-rdoc --no-ri capistrano-npm

RUN echo 'eval $(ssh-agent -s)' >> /root/.bashrc
RUN echo 'ssh-add -D' >> /root/.bashrc
RUN echo "ssh-add ~/.ssh/id_rsa" >> /root/.bashrc
RUN echo "ssh-add /root/.ssh/Frankfurth_Staging_Key1.pem" >> /root/.bashrc

WORKDIR /source

CMD ["/bin/bash"]
