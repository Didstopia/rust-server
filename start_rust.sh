#!/usr/bin/env bash

#pid=0

trap 'exit_handler' SIGHUP SIGINT SIGQUIT SIGTERM
exit_handler()
{
	echo "Shutdown signal received"

	if [ -f "/steamcmd/rust/server/$RUST_SERVER_IDENTITY/UserPersistence.db" ]; then
		# Backup the current blueprint data
		cp -fr "/steamcmd/rust/server/$RUST_SERVER_IDENTITY/UserPersistence.db" "/steamcmd/rust/UserPersistence.db.bak"
	fi
	
	# Execute the RCON shutdown command
	node /shutdown_app/app.js
	sleep 1

	exit
}

# Create the necessary folder structure
if [ ! -d "/steamcmd/rust" ]; then
	echo "Creating folder structure.."
	mkdir -p /steamcmd/rust
fi

# Install/update steamcmd
echo "Installing/updating steamcmd.."
curl -s http://media.steampowered.com/installer/steamcmd_linux.tar.gz | tar -v -C /steamcmd -zx

# Check which branch to use
if [ ! -z ${RUST_BRANCH+x} ]; then
	echo "Using branch arguments: $RUST_BRANCH"
	sed -i "s/app_update 258550.*validate/app_update 258550 $RUST_BRANCH validate/g" /install.txt
else
	sed -i "s/app_update 258550.*validate/app_update 258550 validate/g" /install.txt
fi

# Disable auto-update if start mode is 2
if [ "$RUST_START_MODE" = "2" ]; then
	# Check that Rust exists in the first place
	if [ ! -f "/steamcmd/rust/RustDedicated" ]; then
		# Install Rust from install.txt
		echo "Installing Rust.."
		bash /steamcmd/steamcmd.sh +runscript /install.txt
	else
		echo "Rust seems to be installed, skipping automatic update.."
	fi
else
	# Install/update Rust from install.txt
	echo "Installing/updating Rust.."
	bash /steamcmd/steamcmd.sh +runscript /install.txt

	# Run the update check if it's not been run before
	if [ ! -f "/steamcmd/rust/build.id" ]; then
		./update_check.sh
	else
		OLD_BUILDID="$(cat /steamcmd/rust/build.id)"
		STRING_SIZE=${#OLD_BUILDID}
		if [ "$STRING_SIZE" -lt "6" ]; then
			./update_check.sh
		fi
	fi
fi

# Check if this is actually a modded server
if [ -d "/oxide" ]; then
	# Install/update Oxide
	echo "Installing/updating Oxide.."
	cp -fr /oxide/* /steamcmd/rust/
fi

# Start mode 1 means we only want to update
if [ "$RUST_START_MODE" = "1" ]; then
	echo "Exiting, start mode is 1.."
	exit
fi

# Add RCON support if necessary
RUST_STARTUP_COMMAND=$RUST_SERVER_STARTUP_ARGUMENTS
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
		nginx && sleep 5
		#nginx -g "daemon off;" && sleep 5 ## Used for debugging nginx
	fi
fi

# Check if a special seed override file exists
if [ -f "/steamcmd/rust/seed_override" ]; then
	RUST_SEED_OVERRIDE=`cat /steamcmd/rust/seed_override`
	echo "Found seed override: $RUST_SEED_OVERRIDE"

	# Modify the server identity to include the override seed
	RUST_SERVER_IDENTITY=$RUST_SEED_OVERRIDE
	RUST_SERVER_SEED=$RUST_SEED_OVERRIDE

	# Prepare the identity directory (if it doesn't exist)
	if [ ! -d "/steamcmd/rust/server/$RUST_SEED_OVERRIDE" ]; then
		echo "Creating seed override identity directory.."
		mkdir -p "/steamcmd/rust/server/$RUST_SEED_OVERRIDE"
		if [ -f "/steamcmd/rust/UserPersistence.db.bak" ]; then
			echo "Copying blueprint backup in place.."
			cp -fr "/steamcmd/rust/UserPersistence.db.bak" "/steamcmd/rust/server/$RUST_SEED_OVERRIDE/UserPersistence.db"
		fi
	fi
fi

# Start cron
echo "Starting scheduled task manager.."
node /scheduler_app/app.js &

# Set the working directory
cd /steamcmd/rust

# Run the server
echo "Starting Rust.."
/steamcmd/rust/RustDedicated $RUST_STARTUP_COMMAND +server.identity "$RUST_SERVER_IDENTITY" +server.seed "$RUST_SERVER_SEED"  +server.hostname "$RUST_SERVER_NAME" +server.url "$RUST_SERVER_URL" +server.headerimage "$RUST_SERVER_BANNER_URL" +server.description "$RUST_SERVER_DESCRIPTION"

exit
