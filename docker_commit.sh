#!/bin/bash

# Set Docker to use the machine
eval "$(docker-machine env default)"

docker commit rust-server galaxxius/dockerust:latest
