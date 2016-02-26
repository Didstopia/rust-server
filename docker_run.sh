#!/bin/bash

# Set Docker to use the machine
eval "$(docker-machine env default)"

# Create the necessary folder structure
if [ ! -d "rust_data" ]; then
  	mkdir -p rust_data/backup
	mkdir -p rust_data/config
	mkdir -p rust_data/server
fi

# Run the server
docker run -p 28015:28015 -p 28015:28015/udp -e RUST_SERVER_STARTUP_ARGUMENTS='-batchmode -load -logfile /rust_data/rust.log +server.globalchat 1 +server.identity "docker" +server.port 28015 +server.secure 1 +server.maxplayers 256 +server.hostname "Rust Server [DOCKER]" +server.seed 4 +server.worldsize 4000 +chat.serverlog 1 +server.netlog 1 +server.saveinterval 300 +server.description "A Rust server running inside Docker!" -autoupdate -god 1' -v $(pwd)/rust_data:/rust_data --name rust-server -d didstopia/rust-server:latest
tail -f rust_data/rust.log