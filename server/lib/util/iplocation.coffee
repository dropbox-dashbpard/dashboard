"use strict"

_ = require "lodash"
request = require "request"

IpCache = require './ip.model'
require("http").globalAgent.maxSockets = 10000

exports.ip2location = (req, res) ->
  ip = req.params.ip
  IpCache.location ip, (err, location) ->
    return res.status(500).send() if err?
    res.status(200).json location
