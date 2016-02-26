## Rust server that runs inside a Docker container

# How to run the server
1. Set the ```RUST_SERVER_STARTUP_ARGUMENTS``` environment variable to match your preferred server arguments (defaults are set to ```"-batchmode -load -logfile /rust_data/rust.log"```)
2. Optionally mount ```/rust_data``` somewhere on the host or inside another container to keep your data safe
3. Run the container and enjoy!

The following environment variables are available and should be used individually instead of specifying them in the arguments variable:
```
RUST_SERVER_STARTUP_ARGUMENTS
RUST_SERVER_NAME
RUST_SERVER_DESCRIPTION
RUST_SERVER_URL
RUST_SERVER_BANNER_URL
```