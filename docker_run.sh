#!/bin/bash

./docker_build.sh

# Run a vanilla server
docker run -p 0.0.0.0:28015:28015 -p 0.0.0.0:28015:28015/udp -p 28016:28016 -p 0.0.0.0:8080:8080 -m 2g -v $(pwd)/rust_data_vanilla:/steamcmd/rust -e RUST_START_MODE=2 -e RUST_UPDATE_CHECKING=1 -e RUST_BRANCH="public" -e RUST_UPDATE_BRANCH="public" --name rust-server -it --rm didstopia/rust-server:latest

#docker logs -f rust-server
