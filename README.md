# docker_matecat
Dockerization of the MateCat web CatTool https://github.com/matecat/MateCat

## Prerequisites

- To use this Installation you must **TURN OFF** these local services if you have already installed them:
  * ActiveMQ
  * Redis Server
  * Apache Server
  * MySQL
- To use MateCat you need to have git installed on your machine.
  * Follow the official instructions on the Git site for your system. [Installing Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- To use docker_matecat you need to install docker and docker-compose.
  * Follow the official instructions on the Docker site for your system. 
    * [Install Docker](https://docs.docker.com/engine/installation/)
    * [Install Docker Compose](https://docs.docker.com/compose/install/)

## Configuration

#### MateCat Repository
- Clone MateCat in your physical host if you not have already done that
```bash
cd /your/preferred/installation/path
git clone https://github.com/matecat/MateCat.git
```

#### docker_matecat Repository
- Clone ```docker_matecat``` in another directory
```bash
cd /your/preferred/docker_matecat_path
git clone https://github.com/Ostico/docker_matecat.git
```

- Go inside this new directory, copy ```docker-compose.yml.sample``` to ```docker-compose.yml```
```bash
cp docker-compose.yml.sample docker-compose.yml
```

##### Mounted volumes ( MateCat application )
- Modify ```docker-compose.yml``` file and change the path of the matecat directory to which you just cloned in this example.

```
  volumes:
    - ~/your/preferred/installation/path/MateCat:/var/www/matecat:rw
```

##### Environment ( optional, remove what you do not need )
- Configure XDEBUG if you need it or remove it from the environment variables.
- Configure your SMTP relay host ip/domain and port if you need them or remove from environment variables.
- Configure the url for your custom filters or remove the key to leave the default [translated-matecat-filters](https://translated-matecat-filters-v1.p.mashape.com)
- If you remove all keys, you must delete the ```environment:``` also.
```
  ## Remove this environment block if you don't need it ##
  environment:
    XDEBUG_CONFIG: {{REMOVE THIS ROW OR INSERT YOUR HOST IP}}
    FILTERS_ADDRESS: {{REMOVE THIS ROW OR INSERT YOUR CUSTOM FILTERS ADDRESS}}
    SMTP_HOST: {{REMOVE THIS ROW OR INSERT YOUR SMTP}}
    SMTP_PORT: {{REMOVE THIS ROW OR INSERT SMTP PORT}}
  ## Remove this environment block if you don't need it ##
```

#### Further MateCat configurations ( Advanced users )
More specific configurations can be made directly into your ```docker_matecat/MatecatApache/config.ini``` before docker starts the installation.

Ex: 
```
/your/preferred/docker_matecat_path/docker_matecat/MateCatApache/app_configs/config.ini
```


#### Start Docker
- Start docker-compose
```bash
cd /your/preferred/docker_matecat_path
docker-compose up
```

#### To enable the Google+ login in MateCat
Follow the instructions on the [MateCat Installation guide: Enable Google+ login](http://www.matecat.com/advanced-manual-setup/#egl):
