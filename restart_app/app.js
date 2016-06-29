#!/usr/bin/env node

var serverHostname = 'localhost';
var serverPort = process.env.RUST_RCON_PORT;
var serverPassword = process.env.RUST_RCON_PASSWORD;

var WebSocket = require('ws');
var ws = new WebSocket("ws://" + serverHostname + ":" + serverPort + "/" + serverPassword);
ws.on('open', function open()
{
	setTimeout(function()
	{
		ws.send(createPacket("say NOTICE: We're updating the server in a couple of minutes, get to a safe spot!"));
		setTimeout(function()
		{
			ws.send(createPacket("quit"));
			//ws.send(createPacket("restart 60")); // NOTE: Don't use restart, because that doesn't actually restart the container!
			setTimeout(function()
			{
				ws.close(1000);

				// After 120 seconds, if the server's still running, forcibly shut it down
				setTimeout(function()
				{
					var child_process = require('child_process');
					child_process.execSync('kill -s 2 $(pidof bash)');
				}, 1000 * 120);
			}, 1000);
		}, 1000 * 120);
	}, 1000);
});

function createPacket(command)
{
	var packet =
	{
		Identifier: -1,
		Message: command,
		Name: "WebRcon"
	};
	return JSON.stringify(packet);
}
