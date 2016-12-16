#!/usr/bin/env node

var debug = false;

var child_process = require('child_process');

var startupDelayInSeconds = 60 * 5;
var runIntervalInSeconds = 60 * 5;

if (debug)
{
	startupDelayInSeconds = 1;
	runIntervalInSeconds = 60;
}

// Start the endless loop after a delay (allow the server to start)
setTimeout(function()
{
	checkForUpdates();
}, 1000 * startupDelayInSeconds);

function checkForUpdates()
{
	setTimeout(function()
	{
		if (debug) console.log("Running bash /update_check.sh");
		child_process.exec('bash /update_check.sh', { /*timeout: 60 * 1000,*/ env: process.env }, function (err, stdout, stderr)
		{
			if (debug) console.log("bash /update_check.sh STDOUT: " + stdout);
			if (debug && err) console.log("bash /update_check.sh ERR: " + err);
			if (debug && stderr) console.log("bash /update_check.sh STDERR: " + stderr);
			checkForUpdates();
		});		
	}, 1000 * runIntervalInSeconds);
}
