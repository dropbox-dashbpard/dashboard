"use strict"

express = require('express')

auth = require('../../lib/auth/auth')
router = express.Router()

users = require("./user.controller")
session = require("./session.controller")

###
User api
###
router.post "/users", auth.ensureAuthenticated, auth.ensureGroupAdmin, users.create
router.get "/users/:userId", auth.ensureAuthenticated, users.get
router.get "/users", auth.ensureAuthenticated, users.list
router.post "/users/:userId", auth.ensureAuthenticated, users.update
router.delete "/users/:userId", auth.ensureAuthenticated, auth.ensureGroupAdmin, users.del

# Session Routes
router.post "/login", session.login
router.post "/logout", session.logout
router.post "/session", auth.ensureAuthenticated, session.session

module.exports = router
