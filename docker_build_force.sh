#!/bin/bash

# Set Docker to use the machine
eval "$(docker-machine env default)"

docker build --no-cache -t didstopia/rust-server:latest .
