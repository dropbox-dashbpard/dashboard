"use strict"

express = require('express')

auth = require('../../lib/auth/auth')
router = express.Router()

users = require("./user.controller")
session = require("./session.controller")

###
User api
###
router.post "/users", auth.ensureGroupAdmin, users.create
router.get "/users/:userId", users.get
router.get "/users", users.list
router.post "/users/:userId", users.update
router.delete "/users/:userId", auth.ensureGroupAdmin, users.del

# Session Routes
router.post "/login", session.login
router.post "/logout", session.logout
router.post "/session", session.session

module.exports = router
