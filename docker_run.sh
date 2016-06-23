#!/bin/bash

./docker_build.sh

# Run the server
docker run -p 28015:28015 -p 28016:28016 -p 8080:8080 -m 4g -v $(pwd)/rust_data:/steamcmd/rust -e RUST_RESPAWN_ON_RESTART=1 -e RUST_UPDATE_CHECKING=1 -e RUST_UPDATE_BRANCH="prerelease" --name rust-server -d didstopia/rust-server:latest
docker logs -f rust-server
