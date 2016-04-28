# Rust server that runs inside a Docker container

**NOTE**: This image will install/update on startup. The path ```/steamcmd/rust``` can be mounted on the host for data persistence.  
Also note that this image provides the new web-based RCON, so you should set ```RUST_RCON_PASSWORD``` to a more secure password.

# How to run the server
1. Set the environment variables you wish to modify from below (note the RCON password!)
2. Optionally mount ```/steamcmd/rust``` somewhere on the host or inside another container to keep your data safe
3. Enjoy!

The following environment variables are available:
```
RUST_SERVER_STARTUP_ARGUMENTS (DEFAULT: "-batchmode -load -logfile /dev/stdout +server.identity docker +server.seed 12345 +server.secure 1")
RUST_SERVER_NAME (DEFAULT: "Rust Server [DOCKER]" - The publicly visible server name)
RUST_SERVER_DESCRIPTION (DEFAULT: "This is a Rust server running inside a Docker container!" - The publicly visible server description)
RUST_SERVER_URL (DEFAULT: "https://hub.docker.com/r/didstopia/rust-server/" - The publicly visible server website)
RUST_SERVER_BANNER_URL (DEFAULT: "" - The publicly visible server banner image URL)
RUST_RCON_WEB (DEFAULT "1" - Set to 1 or 0 to enable or disable the web-based RCON server)
RUST_RCON_PORT (DEFAULT: "28016" - RCON server port)
RUST_RCON_PASSWORD (DEFAULT: "docker" - RCON server password, please change this!)
RUST_RESPAWN_ON_RESTART (DEFAULT: "0" - Controls whether to respawn resources on startup)
```

If you need help, have questions or bug submissions, feel free to contact me **@Dids** on Twitter, and on the *Rust Server Owners* Slack community.
