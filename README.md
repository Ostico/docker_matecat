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
- Clone MateCat in your physical host if you not have already done that
```bash
cd /your/preferred/installation/path
git clone https://github.com/matecat/MateCat.git
```

- Clone ```docker_matecat``` in another directory
```bash
cd /your/preferred/docker_matecat_path
git clone https://github.com/Ostico/docker_matecat.git
```

- Go inside this new directory, copy ```docker-compose.yml.sample``` to ```docker-compose.yml```
```bash
cp docker-compose.yml.sample docker-compose.yml
```

- Modify this file and change the path of the matecat directory to which you just cloned in this example.
```
redis:
  image: redis
  ports:
    - 6379:6379
amq:
  build: ./AMQ/
  ports:
    - 61613:61613
    - 8161:8161
mysql:
  build: ./MySQL/
  ports:
    - 3306:3306
matecat:
  build: ./MateCatApache/
  volumes:
    - ~/your/preferred/installation/path/MateCat:/var/www/matecat:rw
  ports:
    - 80:80
    - 9000:9000
    - 22
  links:
    - mysql
    - redis
    - amq
``` 

- Start docker-compose
```bash
cd /your/preferred/docker_matecat_path
docker-compose up
```

#### To enable the Google+ login in MateCat
Follow the instructions on the [MateCat Installation guide: Enable Google+ login](http://www.matecat.com/advanced-manual-setup/#egl):