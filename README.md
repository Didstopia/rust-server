# Rust server that runs inside a Docker container
[![Docker Automated build](https://img.shields.io/docker/automated/didstopia/rust-server.svg)](https://hub.docker.com/r/didstopia/rust-server/)
[![Docker build status](https://img.shields.io/docker/build/didstopia/rust-server.svg)](https://hub.docker.com/r/didstopia/rust-server/)
[![Docker Pulls](https://img.shields.io/docker/pulls/didstopia/rust-server.svg)](https://hub.docker.com/r/didstopia/rust-server/)
[![Docker stars](https://img.shields.io/docker/stars/didstopia/rust-server.svg)](https://hub.docker.com/r/didstopia/rust-server)

**DISCLAIMER:**
```
Cracked or pirated versions of Rust are not supported in any way, shape or form. Please do not post issues regarding these.
```

---

**TUTORIAL**: We've written a guide on how to use this image [here](http://rust.didscraft.com/rust-server-on-linux-using-docker/).

**NOTE**: This image will install/update on startup. The path ```/steamcmd/rust``` can be mounted on the host for data persistence.
Also note that this image provides the new web-based RCON, so you should set ```RUST_RCON_PASSWORD``` to a more secure password.
This image also supports having a modded server (using Oxide), check the ```RUST_OXIDE_ENABLED``` variable below.

# How to run the server
1. Set the environment variables you wish to modify from below (note the RCON password!)
2. Optionally mount ```/steamcmd/rust``` somewhere on the host or inside another container to keep your data safe
3. Enjoy!

The following environment variables are available:
```
RUST_SERVER_STARTUP_ARGUMENTS (DEFAULT: "-batchmode -load -nographics +server.secure 1")
RUST_SERVER_IDENTITY (DEFAULT: "docker" - Mainly used for the name of the save directory)
RUST_SERVER_PORT (DEFAULT: "" - Rust server port 28015 if left blank or numeric value)
RUST_SERVER_QUERYPORT (DEFAULT: "" - Rust server query port 28016 if left blank or numeric value)
RUST_SERVER_SEED (DEFAULT: "12345" - The server map seed, must be an integer)
RUST_SERVER_WORLDSIZE (DEFAULT: "3500" - The map size, must be an integer)
RUST_SERVER_NAME (DEFAULT: "Rust Server [DOCKER]" - The publicly visible server name)
RUST_SERVER_MAXPLAYERS (DEFAULT: "500" - Maximum players on the server, must be an integer)
RUST_SERVER_DESCRIPTION (DEFAULT: "This is a Rust server running inside a Docker container!" - The publicly visible server description)
RUST_SERVER_URL (DEFAULT: "https://hub.docker.com/r/didstopia/rust-server/" - The publicly visible server website)
RUST_SERVER_BANNER_URL (DEFAULT: "" - The publicly visible server banner image URL)
RUST_SERVER_SAVE_INTERVAL (DEFAULT: "600" - Amount of seconds between automatic saves.)
RUST_RCON_WEB (DEFAULT "1" - Set to 1 or 0 to enable or disable the web-based RCON server)
RUST_RCON_PORT (DEFAULT: "28016" - RCON server port)
RUST_RCON_PASSWORD (DEFAULT: "docker" - RCON server password, please change this!)
RUST_APP_PORT (DEFAULT: "28082" - Rust+ companion app port)
RUST_BRANCH (DEFAULT: Not set - Sets the branch argument to use, eg. set to "-beta prerelease" for the prerelease branch)
RUST_UPDATE_CHECKING (DEFAULT: "0" - Set to 1 to enable fully automatic update checking, notifying players and restarting to install updates)
RUST_UPDATE_BRANCH (DEFAULT: "public" - Set to match the branch that you want to use for updating, ie. "prerelease" or "public", but do not specify arguments like "-beta")
RUST_START_MODE (DEFAULT: "0" - Determines if the server should update and then start (0), only update (1) or only start (2))
RUST_OXIDE_ENABLED (DEFAULT: "0" - Set to 1 to automatically install the latest version of Oxide)
RUST_OXIDE_UPDATE_ON_BOOT (DEFAULT: "1" - Set to 0 to disable automatic update of Oxide on boot)
RUST_RCON_SECURE_WEBSOCKET (DEFAULT: "0" - Set to 1 to enable secure websocket connections to the RCON web interface)
RUST_HEARTBEAT (DEFAULT: "0" - Set to 1 to enable the heartbeat service which will forcibly quit the server if it becomes unresponsive to queries)
```

# Logging and rotating logs

The image now supports log rotation, and all you need to do to enable it is to remove any `-logfile` arguments from your startup arguments.
Log files will be created under `logs/` with the server identity and the current date and time.
When the server starts up or restarts, it will move old logs to `logs/archive/`.

# How to send or receive command to/from the server

We recently added a small application, called *rcon*, that can both send and receive messages to the server, much like the console on the Windows version, but this happens to use RCON (webrcon).
To use it, simply run the following on the host: `docker exec rust-server rcon say Hello World`, substituting *rust-server* for your own container name.

# Rust+ companion app support

The image sets up `app.port` to `28082` by default, but you can optionally override this with the `RUST_APP_PORT` environment variable.  
If you need to set additional options, such as `app.listenip` or `app.publicip`, you can supply these to `RUST_SERVER_STARTUP_ARGUMENTS` environment variable, but be careful to also include the default values.  
More information on the Rust+ companion app integration can be found [here](https://wiki.facepunch.com/rust/rust-companion-server).

# Troubleshooting

  - If the server exits by itself after seemingly starting up fine, make sure the Docker VM has at least 4GB of RAM.
  - If you can connect to the RCON web UI, but not the game itself, make sure you've exposed port 28015 as UDP, not TCP.

# Anything else

If you need help, have questions or bug submissions, feel free to contact me **@Dids** on Twitter, and on the *Rust Server Owners* Slack community.
