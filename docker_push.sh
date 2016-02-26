#!/bin/bash

# Set Docker to use the machine
eval "$(docker-machine env default)"

docker tag -f didstopia/rust-server:latest didstopia/rust-server:latest
docker push didstopia/rust-server:latest