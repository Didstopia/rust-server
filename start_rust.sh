#!/bin/bash

# Create the necessary folder structure
if [ ! -d "/steamcmd/rust" ]; then
	echo "Creating folder structure.."
	mkdir -p /steamcmd/rust
fi

# Check if we need to block a service
bash /block.sh

# Install/update steamcmd
echo "Installing/updating steamcmd.."
curl -s http://media.steampowered.com/installer/steamcmd_linux.tar.gz | tar -v -C /steamcmd -zx

# Install/update Rust from install.txt
echo "Installing/updating Rust.."
bash /steamcmd/steamcmd.sh +runscript /install.txt

# Setup paths and run the server
echo "Starting Rust.."
cd /steamcmd/rust
./RustDedicated $RUST_SERVER_STARTUP_ARGUMENTS +server.hostname "$RUST_SERVER_NAME" +server.url "$RUST_SERVER_URL" +server.headerimage "$RUST_SERVER_BANNER_URL" +server.description "$RUST_SERVER_DESCRIPTION"