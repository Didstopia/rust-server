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
		ws.send(createPacket("quit"));
		setTimeout(function()
		{
			ws.close(1000);
		}, 1000);
	}, 1000);
});
ws.on('close', function close()
{
	process.exit(0);
});
ws.on('error', function()
{
	process.exit(1);
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
