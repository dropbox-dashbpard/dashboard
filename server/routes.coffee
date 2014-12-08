###
Main application routes
###
"use strict"
errors = require("./components/errors")
module.exports = (app) ->

  # Insert routes below
  app.use "/auth", require("./lib/auth")
  app.use "/api/0/dropbox", require("./lib/dropbox")
  app.use "/api/0/util", require("./lib/util")
  
  # All undefined asset or api routes should return a 404
  app.route("/:url(api|auth|components|app|bower_components|assets)/*").get errors[404]
  
  # All other routes should redirect to the index.html
  app.route("/*").get (req, res) ->
    res.sendfile app.get("appPath") + "/index.html"
