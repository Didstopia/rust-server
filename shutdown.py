#!/usr/bin/env python
import os
import valve
import valve.source
import valve.source.rcon
from valve.source.rcon import RCON

SERVER_ADDRESS = ("localhost", int(os.environ.get('RUST_RCON_PORT')))
PASSWORD = os.environ.get('RUST_RCON_PASSWORD')

try:
    with RCON(SERVER_ADDRESS, PASSWORD, 5) as rcon:
        rcon("quit")

except valve.source.rcon.NoResponseError:
	print "Server command timed out"
