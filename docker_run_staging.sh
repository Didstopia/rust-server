#!/bin/bash

./docker_build.sh

# Run a staging server
docker run -p 0.0.0.0:28115:28015 -p 0.0.0.0:28115:28015/udp -p 28116:28116 -p 0.0.0.0:8081:8080 -m 2g -v $(pwd)/rust_data_staging:/steamcmd/rust -e RUST_START_MODE=2 -e RUST_UPDATE_CHECKING=1 -e RUST_RCON_PORT=28116 -e RUST_BRANCH="staging" -e RUST_UPDATE_BRANCH="staging" -e RUST_SERVER_STARTUP_ARGUMENTS="-batchmode -load -nographics +server.secure 1" --name rust-server-staging -d didstopia/rust-server:latest

docker logs -f rust-server-staging
