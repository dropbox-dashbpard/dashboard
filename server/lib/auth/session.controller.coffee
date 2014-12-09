"use strict"

passport = require("passport")

###
Logout
###
exports.logout = (req, res) ->
  if req.user
    req.logout()
    res.sendStatus 200
  else
    res.status(400).send "Not logged in"

###
Login
requires: {email, password}
###
exports.login = (req, res, next) ->
  passport.authenticate("local", (err, user, info) ->
    error = err or info
    return res.json(400, error)  if error
    req.logIn user, (err) ->
      return res.send err if err
      res.json req.user.user_info
  ) req, res, next

###
User Info
###
exports.session = (req, res, next) ->
  res.json user: req.user.user_info
