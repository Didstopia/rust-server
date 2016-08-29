#!/bin/bash

./docker_build.sh

# Run a modded server
#docker run -p 0.0.0.0:28015:28015 -p 0.0.0.0:28015:28015/udp -p 28016:28016 -p 0.0.0.0:8080:8080 -m 4g -v $(pwd)/rust_data:/steamcmd/rust -e RUST_SERVER_STARTUP_ARGUMENTS="-batchmode -load -logfile /dev/stdout +server.secure 1 +server.saveinterval 60" -e RUST_UPDATE_CHECKING=1 -e RUST_BRANCH="public" -e RUST_UPDATE_BRANCH="public" -e RUST_OXIDE_ENABLED=1 --name rust-server -d didstopia/rust-server:latest

# Run a vanilla server
#docker run -p 0.0.0.0:28015:28015 -p 0.0.0.0:28015:28015/udp -p 28016:28016 -p 0.0.0.0:8080:8080 -m 4g -v $(pwd)/rust_data:/steamcmd/rust -e RUST_UPDATE_CHECKING=1 -e RUST_BRANCH="public" -e RUST_UPDATE_BRANCH="public" --name rust-server -d didstopia/rust-server:latest

# Run a prerelease server
docker run -p 0.0.0.0:28015:28015 -p 0.0.0.0:28015:28015/udp -p 28016:28016 -p 0.0.0.0:8080:8080 -m 4g -v $(pwd)/rust_data:/steamcmd/rust -e RUST_UPDATE_CHECKING=1 -e RUST_BRANCH="prerelease" -e RUST_UPDATE_BRANCH="prerelease" --name rust-server -d didstopia/rust-server:latest

docker logs -f rust-server
