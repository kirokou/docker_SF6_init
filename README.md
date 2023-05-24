# Docker Application Setup
Setup docker pour projet sf avec les services suivants

## Run Locally
- Clone the project
    
        git clone git@github.com:kirokou/docker_SF6_init.gitRun the docker-compose

- Build docker
    
        docker-compose build
        docker-compose up -d

- Log into the PHP container

        docker exec -it php8-sf6 bash

- Create your Symfony application and launch the internal server

      symfony new new-project --full
      cd new-project
      symfony serve -d

- Create an account (identical to your local session)

      adduser username
      chown username:username -R .

- If you need a database, modify the .env file like this example:

      DATABASE_URL="postgresql://symfony:ChangeMe@database:5432/app?serverVersion=13&charset=utf8"

## Ready to use with
This docker-compose provides you :
- PHP-8.2
- php-apache
- Composer
- Symfony CLI
- some other php extentions : nodejs, npm, yarn
- mysql
- phpmyadmin
- mailer


## Requirements
- Linux/MacOs
- Docker
- Docker-compose