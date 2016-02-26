#!/bin/bash

# Set Docker to use the machine
eval "$(docker-machine env default)"

docker build -t didstopia/rust-server:latest .