#!/bin/bash

./docker_build.sh

# Run a modded server
docker run --network=host -p 0.0.0.0:28215:28015 -p 0.0.0.0:28215:28015/udp -p 28216:28216 -p 0.0.0.0:8082:8080 -m 2g -v $(pwd)/rust_data_modded:/steamcmd/rust -e RUST_SERVER_STARTUP_ARGUMENTS="-batchmode -load -nographics -logfile /dev/stdout +server.secure 1 +server.saveinterval 60" -e RUST_RCON_PORT=28216 -e RUST_UPDATE_CHECKING=0 -e RUST_BRANCH="public" -e RUST_UPDATE_BRANCH="public" -e RUST_OXIDE_ENABLED=1 --name rust-server-modded -d didstopia/rust-server:latest

docker logs -f rust-server-modded
