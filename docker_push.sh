#!/bin/bash

# Set Docker to use the machine
eval "$(docker-machine env default)"

docker tag -f didstopia/rust-server:latest docker.didstopia.com/didstopia/rust-server:latest
docker push docker.didstopia.com/didstopia/rust-server:latest