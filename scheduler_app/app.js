#!/usr/bin/env node

var debug = false

var childProcess = require('child_process')

var startupDelayInSeconds = 60 * 5
var runIntervalInSeconds = 60 * 5

if (debug) {
  startupDelayInSeconds = 1
  runIntervalInSeconds = 60
}

// Start the endless loop after a delay (allow the server to start)
setTimeout(function () {
  checkForUpdates()
}, 1000 * startupDelayInSeconds)

function checkForUpdates () {
  setTimeout(function () {
    if (debug) console.log('SchedulerApp::Running bash /update_check.sh')
    childProcess.exec('bash /update_check.sh', { env: process.env }, function (err, stdout, stderr) {
      if (debug) console.log('SchedulerApp::bash /update_check.sh STDOUT: ' + stdout)
      if (debug && err) console.log('SchedulerApp::bash /update_check.sh ERR: ' + err)
      if (debug && stderr) console.log('SchedulerApp::bash /update_check.sh STDERR: ' + stderr)
      checkForUpdates()
    })
  }, 1000 * runIntervalInSeconds)
}
