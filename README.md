# docker_matecat
Dockerization of the MateCat web CatTool https://github.com/matecat/MateCat

## Prerequisites
To use MateCat you need to have git installed on your machine
Follow the official instructions on the Git site for your system.
[Installing Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

To use docker_matecat you need to install docker and docker-compose.
Follow the official instructions on the Docker site for your system.
[Install Docker Compose](https://docs.docker.com/compose/install/)

### Configuration
- Clone MateCat in your physical host
```bash
cd /your/preferred/installation/path
git clone https://github.com/matecat/MateCat.git
```

- Copy docker-compose.yml.sample to docker-compose.yml and modify the path of the matecat directory you just cloned ( /your/preferred/installation/path in this example ).

- Start docker-compose
```bash
docker-compose up
```

#### To enable the login in MateCat
Add your own oauth_config.ini taken from google.com and uncomment the line on MateCatApache/Dockerfile
