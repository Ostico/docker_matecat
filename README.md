# Matecat in Docker
Friendly fork of [https://github.com/ostico/docker_matecat](https://github.com/ostico/docker_matecat).

Dockerization of the MateCat web CatTool https://github.com/matecat/MateCat

This is a WIP meant to be used in production. It aims at being fully runnable on Kubernetes.

### Improvements over original repo
* Separated the daemons from the web component. Everything runs in a separate container, although shared volumes are required.
* Much of the build now happens... at build time. At runtime only lightweight operations like DB schema initialization and configuration files' tweaking is performed.
* Removed old and deprecated stuff, like Capistrano and Xenial release.
* Fixed some minor glitches here and there that broke the happy build path.

## Prerequisites
### Networking
This binds on local ports like 8732, 3306, 6379, 8161, 61613, 80, 443, 7788.

- To use this Installation you must **TURN OFF** following local services (if you already have them):
  * ActiveMQ
  * Redis Server
  * Apache Server
  * MySQL

### Software
docker and docker-compose. 
Follow the official instructions on the Docker site for your system. 
* [Install Docker](https://docs.docker.com/engine/installation/)
* [Install Docker Compose](https://docs.docker.com/compose/install/)

## Getting started

```bash
git clone https://github.com/aijanai/docker_matecat.git
cd MateCat-Bionic

# init the DB
docker-compose up -d mysql
docker-compose exec mysql ./create_mysql_admin_user.sh

# bring up the rest
docker-compose up -d
```

##### docker-compose Environment ( optional, remove what you do not need )
- Configure XDEBUG if you need it or remove it from the environment variables.
- Configure your SMTP relay host ip/domain and port if you need them or remove from environment variables.
- Configure the url for your custom filters or use the public ones ([translated-matecat-filters](https://translated-matecat-filters-v1.p.mashape.com)).

#### Further MateCat configurations ( Advanced users, not really needed for the average user )
More radical configurations can be made in `inc/config.ini` inside the container. Consider mounting that dir/file.

#### To enable the Google+ login in MateCat
MateCat relies on OAuth.  
Follow the (outdated) instructions on the [MateCat Installation guide: Enable Google+ login](http://www.matecat.com/advanced-manual-setup/#egl):
