### Express configuration ###
"use strict"

express = require("express")
favicon = require("static-favicon")
morgan = require("morgan")
compression = require("compression")
bodyParser = require("body-parser")
busboy = require('connect-busboy')
methodOverride = require("method-override")
cookieParser = require("cookie-parser")
session = require("express-session")
errorHandler = require("errorhandler")
path = require("path")
crypto = require('crypto')

mongoose = require 'mongoose'
MongoStore = require('connect-mongo')(session)

config = require './environment'

module.exports = (app) ->
  env = app.get("env")
  app.set "views", config.root + "/server/views"
  app.engine "html", require("ejs").renderFile
  app.set "view engine", "html"
  app.use compression()
  app.use bodyParser.urlencoded {extended: false, limit: '10mb'}
  app.use bodyParser.json {limit: '10mb'}
  app.use bodyParser.text {limit: '10mb'}
  app.use busboy(
    limits:
      fileSize: 10 * 1024 * 1024
  )
  app.use methodOverride()
  app.use cookieParser(config.secrets.session)

  if "production" is env
    app.use favicon(path.join(config.root, "public", "favicon.ico"))
    app.use express.static(path.join(config.root, "public"))
    app.set "appPath", config.root + "/public"
  if "development" is env or "test" is env
    app.use require("connect-livereload")()
    app.use express.static(path.join(config.root, ".tmp"))
    app.use express.static(path.join(config.root, "client"))
    app.set "appPath", "client"

  app.use session(
    resave: false
    secret: config.secrets.session
    saveUninitialized: true
    store: new MongoStore(
        secret: config.secrets.session
        #url: config.mongo.uri
        db: mongoose.connection.db
        defaultExpirationTime: 1000 * 60 * 60 * 24 # set one day to reduce the sessions count
        collection: 'sessions'
      )
  )

  # passport
  require('./pass') app

  app.use morgan("dev")
  if "development" is env or "test" is env
    app.use errorHandler() # Error handler - has to be last
