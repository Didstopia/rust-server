## Rust server that runs inside a Docker container

NOTE: This image will always install/update to the latest steamcmd and Rust server, all you have to do to update your server is to redeploy the container.

Also note that the entire /steamcmd/rust can be mounted on the host system.

# How to run the server
1. Set the ```RUST_SERVER_STARTUP_ARGUMENTS``` environment variable to match your preferred server arguments (defaults are set to ```"-batchmode -load -logfile /dev/stdout +server.identity docker +server.seed 12345 +server.secure 1"```, note how we're logging to stdout)
2. Optionally mount ```/steamcmd/rust``` somewhere on the host or inside another container to keep your data safe
3. Run the container and enjoy!

The following environment variables are available and should be used individually instead of specifying them in the arguments variable:
```
RUST_SERVER_STARTUP_ARGUMENTS
RUST_SERVER_NAME
RUST_SERVER_DESCRIPTION
RUST_SERVER_URL
RUST_SERVER_BANNER_URL
RUST_RCON_PORT
RUST_RCON_PASSWORD
```

IMPORTANT: You should set both the ```RUST_RCON_PORT``` and RUST_RCON_PASSWORD``` to enable RCON, which will also enable proper server shutdown when Docker sends the shutdown/kill command. It essentially connects to the RCON server and executed the ```quit``` command, which properly shuts down the server.



You can also set the following variables to **"true"** if you want to block a specific service:
```
RUST_SERVER_BLOCK_RUSTIO
```
*Please note that the blocking feature has not been thoroughly tested yet (ie. probably doesn't even work yet) and is constantly being worked on.*