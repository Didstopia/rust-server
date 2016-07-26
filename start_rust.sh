#!/usr/bin/env bash

# Define the exit handler
exit_handler()
{
	echo "Shutdown signal received"

	# Only do backups if we're using the seed override
	if [ -f "/steamcmd/rust/seed_override" ]; then
		# Create the backup directory if it doesn't exist
		if [ ! -d "/steamcmd/rust/bak" ]; then
			mkdir -p /steamcmd/rust/bak
		fi
		if [ -f "/steamcmd/rust/server/$RUST_SERVER_IDENTITY/UserPersistence.db" ]; then
			# Backup all the current unlocked blueprint data
			cp -fr "/steamcmd/rust/server/$RUST_SERVER_IDENTITY/UserPersistence*.db" "/steamcmd/rust/bak/"
		fi

		if [ -f "/steamcmd/rust/server/$RUST_SERVER_IDENTITY/xp.db" ]; then
			# Backup all the current XP data
			cp -fr "/steamcmd/rust/server/$RUST_SERVER_IDENTITY/xp*.db" "/steamcmd/rust/bak/"
		fi
	fi
	
	# Execute the RCON shutdown command
	node /shutdown_app/app.js
	sleep 1

	exit
}

# Trap specific signals and forward to the exit handler
trap 'exit_handler' SIGHUP SIGINT SIGQUIT SIGTERM

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

# Check if Oxide is enabled
if [ "$RUST_OXIDE_ENABLED" = "1" ]; then
	# Next check if Oxide doesn't' exist, or if we want to always update it
	INSTALL_OXIDE="0"
	if [ ! -f "/steamcmd/rust/CSharpCompiler" ]; then
		INSTALL_OXIDE="1"
	fi
	if [ "$RUST_OXIDE_UPDATE_ON_BOOT" = "1" ]; then
		INSTALL_OXIDE="1"
	fi

	# If necessary, download and install latest Oxide
	if [ "$INSTALL_OXIDE" = "1" ]; then
		echo "Downloading and installing latest Oxide.."
		curl -sL https://github.com/OxideMod/Snapshots/raw/master/Oxide-Rust_Linux.zip | bsdtar -xvf- -C /steamcmd/rust/
		chmod +x /steamcmd/rust/CSharpCompiler && chmod +x /steamcmd/rust/CSharpCompiler.x86
		chown -R root:root /steamcmd/rust
	fi
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
		if [ -f "/steamcmd/rust/xp.db.bak" ]; then
			echo "Copying blueprint backup in place.."
			cp -fr "/steamcmd/rust/xp.db.bak" "/steamcmd/rust/server/$RUST_SEED_OVERRIDE/xp.db"
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
/steamcmd/rust/RustDedicated $RUST_STARTUP_COMMAND +server.identity "$RUST_SERVER_IDENTITY" +server.seed "$RUST_SERVER_SEED"  +server.hostname "$RUST_SERVER_NAME" +server.url "$RUST_SERVER_URL" +server.headerimage "$RUST_SERVER_BANNER_URL" +server.description "$RUST_SERVER_DESCRIPTION" &

child=$!
wait "$child"
