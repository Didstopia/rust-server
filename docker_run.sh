#!/bin/bash

./docker_build.sh

# Run a server without a volume mount (also doesn't remove it after termination)
# docker run -p 0.0.0.0:28015:28015 -p 0.0.0.0:28015:28015/udp -p 0.0.0.0:28016:28016 -p 0.0.0.0:8080:8080 --name rust-server -it didstopia/rust-server:latest

# Run a vanilla server
docker run -p 0.0.0.0:28015:28015 -p 0.0.0.0:28015:28015/udp -p 0.0.0.0:28016:28016 -p 0.0.0.0:8080:8080 -v $(pwd)/rust_data:/steamcmd/rust $@ --name rust-server -it --rm didstopia/rust-server:latest
#docker run -p 0.0.0.0:28015:28015 -p 0.0.0.0:28015:28015/udp -p 0.0.0.0:28016:28016 -p 0.0.0.0:8080:8080 -e RUST_SERVER_STARTUP_ARGUMENTS="-batchmode -load -nographics +server.secure 1 -logfile /dev/null" -e RUST_START_MODE="2" -v $(pwd)/rust_data:/steamcmd/rust --name rust-server -it --rm didstopia/rust-server:latest

# Run a modded server
#docker run -p 0.0.0.0:28015:28015 -p 0.0.0.0:28015:28015/udp -p 0.0.0.0:28016:28016 -p 0.0.0.0:8080:8080 -e RUST_OXIDE_ENABLED=1 -v $(pwd)/rust_data:/steamcmd/rust --name rust-server -it --rm didstopia/rust-server:latest
