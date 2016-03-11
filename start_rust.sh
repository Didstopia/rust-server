#!/bin/bash
STEAM_PATH=/steamcmd
RUST_PATH=$STEAM_PATH/rust

# Start the cron service in the background
cron -f &
#/usr/bin/crontab /etc/cron.d/rust-rsync

# When starting the server, we rsync both ways
rsync -rtuv /data/ /steamcmd/rust/server
rsync -rtuv /steamcmd/rust/server/ /data

./RustDedicated $RUST_SERVER_STARTUP_ARGUMENTS +server.hostname "$RUST_SERVER_NAME" +server.url "$RUST_SERVER_URL" +server.headerimage "$RUST_SERVER_BANNER_URL" +server.description "$RUST_SERVER_DESCRIPTION"