## Rust server that runs inside a Docker container

NOTE: This image has been updated so that it installs/updates Rust on startup!

Since this image will always install/update to the latest steamcmd and Rust server, all you have to do to update your server is to redeploy the container.
Also note that the entire /steamcmd should be mounted on the host system to avoid potential saving issues with Rust.

# How to run the server
1. Set the ```RUST_SERVER_STARTUP_ARGUMENTS``` environment variable to match your preferred server arguments (defaults are set to ```"-batchmode -load -logfile /dev/stdout +server.identity docker +server.seed 12345 +server.secure 1"```, note how we're logging to stdout)
2. Optionally mount ```/steamcmd``` somewhere on the host or inside another container to keep your data safe
3. Run the container and enjoy!

The following environment variables are available and should be used individually instead of specifying them in the arguments variable:
```
RUST_SERVER_STARTUP_ARGUMENTS
RUST_SERVER_NAME
RUST_SERVER_DESCRIPTION
RUST_SERVER_URL
RUST_SERVER_BANNER_URL
```
