#!/bin/bash

# 1. set variables

DB_IMAGE=postgres:13-alpine
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=postgres

# 1. pull DB image

docker pull $DB_IMAGE

# 2. run DB container

docker run --name postgres -d \
  -e POSTGRES_USER=$DB_USER \
  -e POSTGRES_PASSWORD=$DB_PASSWORD \
  -e POSTGRES_DB=$DB_NAME \
  -p 5432:5432 \
  -v $HOME/docker/volumes/postgres:/var/lib/postgresql/data \
  $DB_IMAGE
