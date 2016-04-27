#!/bin/bash

# Set Docker to use the machine
eval "$(docker-machine env default)"

# Run the server
docker run -p 28015:28015 -p 28016:28016 -p 80:8080 -v $(pwd)/rust_data:/steamcmd/rust -e RUST_RESPAWN_ON_RESTART=1 --name rust-server -d didstopia/rust-server:latest
docker logs -f rust-server
