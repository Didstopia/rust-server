#!/bin/bash

# Set Docker to use the machine
eval "$(docker-machine env default)"

docker tag -f galaxxius/dockerust:latest galaxxius/dockerust:latest
docker push galaxxius/dockerust:latest