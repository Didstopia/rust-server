#!/bin/bash

# Set Docker to use the machine
eval "$(docker-machine env default)"

# Run the server
docker run -p 28015:28015 -p 28015:28015/udp -e RUST_SERVER_STARTUP_ARGUMENTS='-batchmode -load -logfile /dev/stdout +server.globalchat 1 +server.identity "docker" +server.port 28015 +server.secure 1 +server.maxplayers 256 +server.hostname "Rust Server [DOCKER]" +server.seed 82041 +server.worldsize 3000 +chat.serverlog 1 +server.netlog 1 +server.saveinterval 300 +server.description "A Rust server running inside Docker!" -autoupdate -god 1' -v $(pwd)/rust_data:/data --name rust-server -d didstopia/rust-server:latest
docker logs -f rust-server