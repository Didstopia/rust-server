#!/bin/bash

# $scope.Address = $scope.Address.trim();

# Replace the trimmed address field with the current domain/hostname and RCON port
OLD_TRIM_CODE='scope.Address = $scope.Address.trim();'
NEW_ADDRESS_CODE='scope.Address = $location.host() + '"\":$RUST_RCON_PORT\";"
if [ ! -z "$RUST_RCON_HOSTNAME" ]; then
	NEW_ADDRESS_CODE='scope.Address = '"\"$RUST_RCON_HOSTNAME:$RUST_RCON_PORT\";"
fi
sed -i -e 's/'"$OLD_TRIM_CODE"'/'"$NEW_ADDRESS_CODE"'/g' /usr/share/nginx/html/js/connection.js

# Replace the help text with our own
OLD_HELP_TEXT="Enter the address (including rcon port) and the rcon password below to connect."
NEW_HELP_TEXT="Enter the rcon password below to connect."
sed -i -e 's/'"$OLD_HELP_TEXT"'/'"$NEW_HELP_TEXT"'/g' /usr/share/nginx/html/html/connect.html

# Remove the address lines (14-19) if they exist
if grep -q "ng-model=\"Address\"" /usr/share/nginx/html/html/connect.html; then
	sed -i -e '14,19d' /usr/share/nginx/html/html/connect.html
fi
