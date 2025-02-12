#!/bin/bash

pushd ./harbor
docker-compose stop
docker-compose start
popd
