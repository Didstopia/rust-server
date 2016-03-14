#!/bin/bash

# Set Docker to use the machine
eval "$(docker-machine env default)"

# Run the server
docker run -p 28015:28015 -p 28015:28015/udp -v $(pwd)/rust_data:/steamcmd --name rust-server -d didstopia/rust-server:latest
docker logs -f rust-server