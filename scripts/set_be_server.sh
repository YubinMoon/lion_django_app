#!/bin/sh

export $(cat .env | xargs)

DOCKER_IMAGE=$NCR_REGISTRY/lion-app:latest

docker login -u $DOCKER_USER -p $DOCKER_PASSWORD $NCR_REGISTRY

docker run -d --name lion-app \
  --env-file .env \
  -e DB_HOST=$DB_HOST \
  -p 8000:8000 \
  $DOCKER_IMAGE \
  /start
