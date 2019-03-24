#!/usr/bin/env node

var debug = false

var request = require('request')
var isRestarting = false
var now = Math.floor(new Date() / 1000)
var timeout = (1000 * 60) * 30
var updateCheckInterval = (1000 * 60) * 5

if (debug) {
  updateCheckInterval = 5000 // Check every 5 seconds
  timeout = 1000 * 60 // Timeout after a minute
}

// Timeout after 30 minutes and restart
setTimeout(function () {
  console.log('RestartApp::Timeout exceeded, forcing a restart')
  restart()
}, timeout)

// Start checking for client updates
checkForClientUpdate()

function checkForClientUpdate () {
  if (isRestarting) {
    if (debug) console.log("RestartApp::We're restarting, skipping client update check..")
    return
  }

  console.log('RestartApp::Checking if a client update is available..')
  request({ url: 'https://whenisupdate.com/api.json', headers: { Referer: 'rust-docker-server' }, timeout: 10000 }, function (error, response, body) {
    if (!error && response.statusCode === 200) {
      var info = JSON.parse(body)
      var latest = info.latest
      if (latest !== undefined && latest.length > 0) {
        if (latest >= now) {
          console.log('RestartApp::Client update is out, forcing a restart')
          restart()
          return
        }
      }
      if (debug) console.log('RestartApp::Client update not out yet..')
    } else if (debug) {
      console.log('RestartApp::Error: ' + error)
    }

    // Keep checking for client updates every 5 minutes
    setTimeout(function () {
      checkForClientUpdate()
    }, updateCheckInterval)
  })
}

function restart () {
  if (debug) console.log('RestartApp::Restarting..')
  if (isRestarting) {
    if (debug) console.log("RestartApp::We're already restarting..")
    return
  }
  isRestarting = true

  var serverHostname = 'localhost'
  var serverPort = process.env.RUST_RCON_PORT
  var serverPassword = process.env.RUST_RCON_PASSWORD

  var WebSocket = require('ws')
  var ws = new WebSocket('ws://' + serverHostname + ':' + serverPort + '/' + serverPassword)
  ws.on('open', function open () {
    setTimeout(function () {
      ws.send(createPacket("say NOTICE: We're updating the server in <color=orange>5 minutes</color>, so get to a safe spot!"))
      setTimeout(function () {
        ws.send(createPacket("say NOTICE: We're updating the server in <color=orange>4 minutes</color>, so get to a safe spot!"))
        setTimeout(function () {
          ws.send(createPacket("say NOTICE: We're updating the server in <color=orange>3 minutes</color>, so get to a safe spot!"))
          setTimeout(function () {
            ws.send(createPacket("say NOTICE: We're updating the server in <color=orange>2 minutes</color>, so get to a safe spot!"))
            setTimeout(function () {
              ws.send(createPacket("say NOTICE: We're updating the server in <color=orange>1 minute</color>, so get to a safe spot!"))
              setTimeout(function () {
                ws.send(createPacket('global.kickall <color=orange>Updating/Restarting</color>'))
                setTimeout(function () {
                  ws.send(createPacket('quit'))
                  // ws.send(createPacket("restart 60")); // NOTE: Don't use restart, because that doesn't actually restart the container!
                  setTimeout(function () {
                    ws.close(1000)

                    // After 2 minutes, if the server's still running, forcibly shut it down
                    setTimeout(function () {
                      var fs = require('fs')
                      fs.unlinkSync('/tmp/restart_app.lock')

                      var childProcess = require('child_process')
                      childProcess.execSync('kill -s 2 $(pidof bash)')
                    }, 1000 * 60 * 2)
                  }, 1000)
                }, 1000)
              }, 1000 * 60)
            }, 1000 * 60)
          }, 1000 * 60)
        }, 1000 * 60)
      }, 1000 * 60)
    }, 1000)
  })
}

function createPacket (command) {
  var packet =
  {
    Identifier: -1,
    Message: command,
    Name: 'WebRcon'
  }
  return JSON.stringify(packet)
}
