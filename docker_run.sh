#!/bin/bash

# Set Docker to use the machine
eval "$(docker-machine env default)"

# Run the server
docker run -v $(pwd)/rust_data:/steamcmd/rust -e RUST_SERVER_BLOCK_RUSTIO="true" -e RUST_SERVER_BLOCK_PLAYRUSTHQ="true" --name rust-server -d didstopia/rust-server:latest
docker logs -f rust-server
