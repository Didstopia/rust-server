#!/bin/bash
STEAM_PATH=/steamcmd
RUST_PATH=$STEAM_PATH/rust
./RustDedicated $RUST_SERVER_STARTUP_ARGUMENTS +server.hostname "$RUST_SERVER_NAME" +server.url "$RUST_SERVER_URL" +server.headerimage "$RUST_SERVER_BANNER_URL" +server.description "$RUST_SERVER_DESCRIPTION"