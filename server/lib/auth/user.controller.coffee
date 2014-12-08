"use strict"

passport = require("passport")
ObjectId = require('mongoose').Types.ObjectId
User = require('./user.model').User

###*
Create user
requires: {username, password, email}
returns: {email, password}
###
exports.create = (req, res, next) ->
  newUser = new User(req.body)
  newUser.provider = "local"
  newUser.save (err) ->
    return res.json(400, err) if err
    req.logIn newUser, (err) ->
      return next(err) if err
      res.json newUser.user_info

###*
Show profile
returns {username, profile}
###
exports.show = (req, res, next) ->
  userId = req.params.userId
  User.findById ObjectId(userId), (err, user) ->
    return next(new Error("Failed to load User")) if err
    if user
      res.send
        username: user.username
        profile: user.profile
    else
      res.send 404, "USER_NOT_FOUND"

###*
Username exists
returns {exists}
###
exports.exists = (req, res, next) ->
  username = req.params.username
  User.findOne
    username: username
  , (err, user) ->
    return next(new Error("Failed to load User " + username))  if err
    if user
      res.json exists: true
    else
      res.json exists: false
