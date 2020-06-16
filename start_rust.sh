#!/usr/bin/env bash

# Enable debugging
#set -x

# Print the user we're currently running as
echo "Running as user: $(whoami)"

# Define the exit handler
exit_handler()
{
	echo "Shutdown signal received"

	# Execute the RCON shutdown command
	node /app/shutdown_app/app.js
	killer=$!
	wait "$killer"

	# Stop the web server
	pkill -f nginx

	echo "Exiting.."
	exit
}

# Trap specific signals and forward to the exit handler
trap 'exit_handler' SIGINT SIGTERM

# Rust includes a 64-bit version of steamclient.so, so we need to tell the OS where it exists
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/steamcmd/rust/RustDedicated_Data/Plugins/x86_64

# Define the install/update function
install_or_update()
{
	# Install Rust from install.txt
	echo "Installing or updating Rust.. (this might take a while, be patient)"
	bash /steamcmd/steamcmd.sh +runscript /app/install.txt

	# Terminate if exit code wasn't zero
	if [ $? -ne 0 ]; then
		echo "Exiting, steamcmd install or update failed!"
		exit 1
	fi
}

# Remove old lock files (used by restart_app/ and update_check.sh)
rm -fr /tmp/*.lock

# Create the necessary folder structure
if [ ! -d "/steamcmd/rust" ]; then
	echo "Missing /steamcmd/rust, creating.."
	mkdir -p /steamcmd/rust
fi
if [ ! -d "/steamcmd/rust/server/${RUST_SERVER_IDENTITY}" ]; then
	echo "Missing /steamcmd/rust/server/${RUST_SERVER_IDENTITY}, creating.."
	mkdir -p "/steamcmd/rust/server/${RUST_SERVER_IDENTITY}"
fi

# Install/update steamcmd
echo "Installing/updating steamcmd.."
curl -s http://media.steampowered.com/installer/steamcmd_linux.tar.gz | bsdtar -xvf- -C /steamcmd

# Check which branch to use
if [ ! -z ${RUST_BRANCH+x} ]; then
	echo "Using branch arguments: $RUST_BRANCH"

	# Add "-beta" if necessary
	INSTALL_BRANCH="${RUST_BRANCH}"
	if [ ! "$RUST_BRANCH" == "public" ]; then
	    INSTALL_BRANCH="-beta ${RUST_BRANCH}"
	fi
	sed -i "s/app_update 258550.*validate/app_update 258550 $INSTALL_BRANCH validate/g" /app/install.txt
else
	sed -i "s/app_update 258550.*validate/app_update 258550 validate/g" /app/install.txt
fi

# Disable auto-update if start mode is 2
if [ "$RUST_START_MODE" = "2" ]; then
	# Check that Rust exists in the first place
	if [ ! -f "/steamcmd/rust/RustDedicated" ]; then
		install_or_update
	else
		echo "Rust seems to be installed, skipping automatic update.."
	fi
else
	install_or_update

	# Run the update check if it's not been run before
	if [ ! -f "/steamcmd/rust/build.id" ]; then
		./app/update_check.sh
	else
		OLD_BUILDID="$(cat /steamcmd/rust/build.id)"
		STRING_SIZE=${#OLD_BUILDID}
		if [ "$STRING_SIZE" -lt "6" ]; then
			./app/update_check.sh
		fi
	fi
fi

# Check if Oxide is enabled
if [ "$RUST_OXIDE_ENABLED" = "1" ]; then
	# Next check if Oxide doesn't' exist, or if we want to always update it
	INSTALL_OXIDE="0"
	if [ ! -f "/steamcmd/rust/CSharpCompiler.x86_x64" ]; then
		INSTALL_OXIDE="1"
	fi
	if [ "$RUST_OXIDE_UPDATE_ON_BOOT" = "1" ]; then
		INSTALL_OXIDE="1"
	fi

	# If necessary, download and install latest Oxide
	if [ "$INSTALL_OXIDE" = "1" ]; then
		echo "Downloading and installing latest Oxide.."
		OXIDE_URL="https://umod.org/games/rust/download/develop"
		curl -sL $OXIDE_URL | bsdtar -xvf- -C /steamcmd/rust/
		chmod 755 /steamcmd/rust/CSharpCompiler.x86_x64 > /dev/null 2>&1 &
	fi
fi

# Start mode 1 means we only want to update
if [ "$RUST_START_MODE" = "1" ]; then
	echo "Exiting, start mode is 1.."
	exit
fi

# Remove extra whitespace from startup command
RUST_STARTUP_COMMAND=$(echo "$RUST_SERVER_STARTUP_ARGUMENTS" | tr -s " ")

# Add RCON support if necessary
if [ ! -z ${RUST_RCON_PORT+x} ]; then
	RUST_STARTUP_COMMAND="$RUST_STARTUP_COMMAND +rcon.port $RUST_RCON_PORT"
fi
if [ ! -z ${RUST_RCON_PASSWORD+x} ]; then
	RUST_STARTUP_COMMAND="$RUST_STARTUP_COMMAND +rcon.password $RUST_RCON_PASSWORD"
fi

if [ ! -z ${RUST_RCON_WEB+x} ]; then
	RUST_STARTUP_COMMAND="$RUST_STARTUP_COMMAND +rcon.web $RUST_RCON_WEB"
	if [ "$RUST_RCON_WEB" = "1" ]; then
		# Fix the webrcon (customizes a few elements)
		bash /tmp/fix_conn.sh

		# Start nginx (in the background)
		echo "Starting web server.."
		nginx
		NGINX=$!
		sleep 5
	fi
fi

# Disable logrotate if "-logfile" is set in $RUST_STARTUP_COMMAND
LOGROTATE_ENABLED=1
RUST_STARTUP_COMMAND_LOWERCASE=`echo "$RUST_STARTUP_COMMAND" | sed 's/./\L&/g'`
if [[ $RUST_STARTUP_COMMAND_LOWERCASE == *" -logfile "* ]]; then
	LOGROTATE_ENABLED=0
fi

if [ "$LOGROTATE_ENABLED" = "1" ]; then
	echo "Log rotation enabled!"

	# Log to stdout by default
	RUST_STARTUP_COMMAND="$RUST_STARTUP_COMMAND -logfile /dev/stdout"
	echo "Using startup arguments: $RUST_SERVER_STARTUP_ARGUMENTS"

	# Create the logging directory structure
	if [ ! -d "/steamcmd/rust/logs/archive" ]; then
		mkdir -p /steamcmd/rust/logs/archive
	fi

	# Set the logfile filename/path
	DATE=`date '+%Y-%m-%d_%H-%M-%S'`
	RUST_SERVER_LOG_FILE="/steamcmd/rust/logs/$RUST_SERVER_IDENTITY"_"$DATE.txt"

	# Archive old logs
	echo "Cleaning up old logs.."
	mv /steamcmd/rust/logs/*.txt /steamcmd/rust/logs/archive | true
else
	echo "Log rotation disabled!"
fi

# Disable logging to stdout/stderr if "-logfile /dev/" is used
STDLOG_ENABLED=1
if [[ $RUST_STARTUP_COMMAND_LOWERCASE == *" -logfile /dev/"* ]]; then
	echo "Disabling internal stdout/stderr logging!"
	STDLOG_ENABLED=0
fi

# Start the scheduler (only if update checking is enabled)
if [ "$RUST_UPDATE_CHECKING" = "1" ]; then
	echo "Starting scheduled task manager.."
	node /app/scheduler_app/app.js &
fi

# Set the working directory
cd /steamcmd/rust

# Run the server
echo "Starting Rust.."
if [ "$RUST_SERVER_PORT" != "" ]; then
	RUST_SERVER_PORT="+server.port $RUST_SERVER_PORT"
fi
if [ "$LOGROTATE_ENABLED" = "1" ]; then
	unbuffer /steamcmd/rust/RustDedicated $RUST_STARTUP_COMMAND "$RUST_SERVER_PORT" +server.identity "$RUST_SERVER_IDENTITY" +server.seed "$RUST_SERVER_SEED" +server.hostname "$RUST_SERVER_NAME" +server.url "$RUST_SERVER_URL" +server.headerimage "$RUST_SERVER_BANNER_URL" +server.description "$RUST_SERVER_DESCRIPTION" +server.worldsize "$RUST_SERVER_WORLDSIZE" +server.maxplayers "$RUST_SERVER_MAXPLAYERS" +server.saveinterval "$RUST_SERVER_SAVE_INTERVAL" +app.port "$RUST_APP_PORT" 2>&1 | grep --line-buffered -Ev '^\s*$|Filename' | tee $RUST_SERVER_LOG_FILE &
elif [ "$STDLOG_ENABLED" = "1" ]; then
	/steamcmd/rust/RustDedicated $RUST_STARTUP_COMMAND "$RUST_SERVER_PORT" +server.identity "$RUST_SERVER_IDENTITY" +server.seed "$RUST_SERVER_SEED" +server.hostname "$RUST_SERVER_NAME" +server.url "$RUST_SERVER_URL" +server.headerimage "$RUST_SERVER_BANNER_URL" +server.description "$RUST_SERVER_DESCRIPTION" +server.worldsize "$RUST_SERVER_WORLDSIZE" +server.maxplayers "$RUST_SERVER_MAXPLAYERS" +server.saveinterval "$RUST_SERVER_SAVE_INTERVAL" +app.port "$RUST_APP_PORT" 2>&1 &
else
	/steamcmd/rust/RustDedicated $RUST_STARTUP_COMMAND "$RUST_SERVER_PORT" +server.identity "$RUST_SERVER_IDENTITY" +server.seed "$RUST_SERVER_SEED" +server.hostname "$RUST_SERVER_NAME" +server.url "$RUST_SERVER_URL" +server.headerimage "$RUST_SERVER_BANNER_URL" +server.description "$RUST_SERVER_DESCRIPTION" +server.worldsize "$RUST_SERVER_WORLDSIZE" +server.maxplayers "$RUST_SERVER_MAXPLAYERS" +server.saveinterval "$RUST_SERVER_SAVE_INTERVAL" +app.port "$RUST_APP_PORT" &
fi

child=$!
wait "$child"

pkill -f nginx

echo "Exiting.."
exit
