#!/usr/bin/env node

var argumentString = ''
var args = process.argv.splice(process.execArgv.length + 2)
for (var i = 0; i < args.length; i++) {
  if (i === args.length - 1) argumentString += args[i]
  else argumentString += args[i] + ' '
}

if (argumentString.length < 1) {
  console.log('RconApp::Error: Please specify an RCON command')
  process.exit()
}

console.log('RconApp::Relaying RCON command: ' + argumentString)

var serverHostname = 'localhost'
var serverPort = process.env.RUST_RCON_PORT
var serverPassword = process.env.RUST_RCON_PASSWORD

var messageSent = false
var WebSocket = require('ws')
var ws = new WebSocket('ws://' + serverHostname + ':' + serverPort + '/' + serverPassword)
ws.on('open', function open () {
  setTimeout(function () {
    messageSent = true
    ws.send(createPacket(argumentString))
    setTimeout(function () {
      ws.close(1000)
      setTimeout(function () {
        console.log('RconApp::Command relayed')
        process.exit()
      })
    }, 1000)
  }, 250)
})
ws.on('message', function (data, flags) {
  if (!messageSent) return
  try {
    var json = JSON.parse(data)
    if (json !== undefined) {
      if (json.Message !== undefined && json.Message.length > 0) {
        console.log('RconApp::Received message:', json.Message)
      }
    } else console.log('RconApp::Error: Invalid JSON received')
  } catch (e) {
    if (e) console.log('RconApp::Error:', e)
  }
})
ws.on('error', function (e) {
  console.log('RconApp::Error:', e)
  process.exit()
})

function createPacket (command) {
  var packet =
  {
    Identifier: -1,
    Message: command,
    Name: 'WebRcon'
  }
  return JSON.stringify(packet)
}
