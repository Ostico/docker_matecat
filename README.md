# docker_matecat
Dockerization of the MateCat web CatTool https://github.com/matecat/MateCat


## Configuration
- Clone MateCat on your local physical host. https://github.com/matecat/MateCat
- Copy docker-compose.yml.sample to docker-compose.yml and modify the path of your installation.
- Start docker-compose

### To enable the login in MateCat
Add your own oauth_config.ini taken from google.com and uncomment the line on MateCatApache/Dockerfile
