#!/usr/bin/env node

var serverHostname = 'localhost'
var serverPort = process.env.RUST_RCON_PORT
var serverPassword = process.env.RUST_RCON_PASSWORD

console.log('ShutdownApp::RCON connecting to server')

var WebSocket = require('ws')
var ws = new WebSocket('ws://' + serverHostname + ':' + serverPort + '/' + serverPassword)
ws.on('open', function open () {
  console.log('ShutdownApp::RCON connection opened')
  setTimeout(function () {
    console.log('ShutdownApp::RCON sending "save" command')
    setTimeout(function () {
      console.log('ShutdownApp::RCON sending "quit" command')
      ws.send(createPacket('quit'))
      setTimeout(function () {
        console.log('ShutdownApp::RCON terminating')
        ws.close(1000)
      }, 1000)
    }, 1000)
  }, 1000)
})
ws.on('close', function close () {
  console.log('ShutdownApp::RCON connection closed')
  process.exit(0)
})
ws.on('error', function (err) {
  console.log('ShutdownApp::RCON error:', err)
  process.exit(1)
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
