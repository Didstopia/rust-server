#!/bin/bash

./docker_build.sh

# Run the server
docker run -p 28015:28015 -p 28016:28016 -p 8080:8080 -m 4g -v $(pwd)/rust_data:/steamcmd/rust --name rust-server -d didstopia/rust-server:latest
docker logs -f rust-server
