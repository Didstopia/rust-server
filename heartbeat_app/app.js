#!/usr/bin/env node
const debug = false;

const query = require('source-server-query');
const childProcess = require('child_process')

var serverHostname = 'localhost';
var serverPort = process.env.RUST_SERVER_PORT;
var rconPort = process.env.RUST_RCON_PORT;
var rconPassword = process.env.RUST_RCON_PASSWORD;

var started = false;
var failcount = 0;
const maxfails = 3;
const querytimeout = 3000;
const checkfreq = 60000;
const processname = '/steamcmd/rust/RustDedicated';

async function check_server () {
	var pass = false;
	var qo = null;

	await query.info('127.0.0.1',serverPort, querytimeout).then((q) => { qo=q;  pass= true; } ).catch((error) => { return });
	if (started) {
		if (pass) {
			if (debug) console.log(`Heartbeat::Running... (Players: ${qo.players})`)
			failcount = 0;
		} else {
			if (debug) console.log("Heartbeat::Failed to respond...");
			failcount++;
			if (failcount >= maxfails) {
				if (debug) console.log("Heartbeat::Max Fails hit! Restarting...");
				clearInterval(timer);
				restart_server();
			}
		}
	} else {
		if (pass) {
			if (debug) console.log("Heartbeat::Started...");
			started = true;
		} else {
			if (debug) console.log("Heartbeat::Waiting for start...");
		}
	}
}

var timer = setInterval(check_server, checkfreq);

function restart_server () {
	console.log('Heartbeat::Restarting...')

	var WebSocket = require('ws');
	var ws = new WebSocket('ws://' + serverHostname + ':' + rconPort + '/' + rconPassword);
	ws.on('open', function open() { 
		if (debug) console.log('Heartbeat::Sending rcon quit...')
		rcon_send('global.kickall Restarting', ws);
		rcon_send('quit', ws);
	})
	setTimeout(kill_rust, 60 * 1000, 2);
	setTimeout(kill_rust, 90 * 1000, 15);
	setTimeout(kill_rust, 120 * 1000, 9);
}


function rcon_send (command, ws) {
	var packet = {
		Identifier: -1,
		Message: command,
		Name: 'WebRcon'
	}
	ws.send(JSON.stringify(packet));
}

function kill_rust (signal) {
	console.log(`Heatbeat::Terminating Process... signal: ${signal}`)
	childProcess.execSync(`kill -s ${signal} $(pidof ${processname})`);
}
