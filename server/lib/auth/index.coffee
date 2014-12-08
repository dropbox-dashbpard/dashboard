"use strict"

express = require('express')

auth = require('../../lib/auth/auth')
router = express.Router()

users = require("./user.controller")
session = require("./session.controller")

  # app.post "/users", users.create
  # app.get "/users/:userId", users.show
  
  # Session Routes
router.post "/login", session.login
router.post "/logout", session.logout
router.post "/session", session.session

module.exports = router