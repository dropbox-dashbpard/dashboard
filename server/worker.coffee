'use strict'

require('http').globalAgent.maxSockets = 10000

request = require('request')
Agenda = require('agenda')
crypto = require('crypto')
_ = require('lodash')

agenda = new Agenda db: { address: process.env.MONGODB_URI or "mongodb://localhost/dbboard" }

agenda.define 'update alps versions', (job, done) ->
  sign = crypto.createHash('md5').update("p=alps#{process.env.SIGN_SECRET}").digest('hex')
  request "http://api.ota.xinqitec.com/ver/get?p=alps&sign=#{sign}", (err, res, body) ->
    if body
      try
        versions = JSON.parse(body).versions
        rel = _.uniq(_.map(versions.release, (ver) -> ver.version_name))
        dev = _.filter(_.uniq(_.map(versions.develop, (ver) -> ver.version_name)), (v) -> v not in rel)
        request
          uri: "http://cr.ota.xinqitec.com/api/0/dropbox/product/alps/dist/development/version"
          method: 'POST'
          json: true
          body:
            versions: dev
          headers:
            Authorization:"Bearer #{process.env.TOKEN}"
        , (err, res, body) ->
          if err
            console.log err
          else
            console.log "Updating development versions done"

        request
          uri: "http://cr.ota.xinqitec.com/api/0/dropbox/product/alps/dist/production/version"
          method: 'POST'
          json: true
          body:
            versions: rel
          headers:
            Authorization:"Bearer #{#{process.env.TOKEN}}"
        , (err, res, body) ->
          if err
            console.log err
          else
            console.log "Updating production versions done"
      catch e
        # ...
      
    done(err)

agenda.every('10 minutes', 'update alps versions')
agenda.start()
