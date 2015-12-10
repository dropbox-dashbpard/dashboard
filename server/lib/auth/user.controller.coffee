'use strict'

passport = require('passport')
uuid = require('node-uuid')
_ = require('lodash')
ObjectId = require('mongoose').Types.ObjectId

User = require('./user.model').User
UserGroup = require('./user.model').UserGroup

###
Create user
requires: {username, password, email}
returns: {email, password}
###
exports.create = (req, res, next) ->
  newUser = new User(req.body)
  if not req.user.admin
    newUser.group = req.user.group
  newUser.provider = 'local'
  newUser.save (err, user) ->
    return res.json(400, err) if err
    res.json newUser.user_info
    UserGroup.findByIdAndUpdate user.group, {$setOnInsert: {token: uuid.v4()}}, {upsert: true}, (err) ->

###
List users
###
exports.list = (req, res, next) ->
  op = if req.user.admin
    {}
  else if not req.user.guest
    group: req.user.group
  else
    _id: req.user._id
  User.find op, (err, users) ->
    return next err if err
    res.json _.map users or [], (user) ->
      user.user_info

###
Show profile
returns {username, profile}
###
exports.get = (req, res, next) ->
  userId = req.params.userId
  User.findById ObjectId(userId), (err, user) ->
    return next err if err
    if user and (user.group is req.user.group or req.user.admin)
      res.json user.user_info
    else
      res.status(404).send 'USER_NOT_FOUND'

###
Update user info
###
exports.update = (req, res, next) ->
  userId = req.params.userId
  User.findById userId, (err, user) ->
    return next err if err
    return res.status(404).send 'Not Found!' if not user
    if req.user.admin or req.user.group is user?.group
      if req.param('email')
        user.email = req.param('email')
      if req.param('username')
        user.username = req.param('username')
      if req.param('password')
        user.password = req.param('password')
      if req.param('name')
        user.name = req.param('name')
      if req.user.admin
        user.admin = req.param('admin') or false
      if not req.user.guest
        user.guest = req.param('guest') or false
      user.save (err, u) ->
        return next err if err
        res.json user.user_info
    else
      res.status(401).send 'No permission!'

###
Delete user
###
exports.del = (req, res, next) ->
  userId = req.params.userId
  User.findById ObjectId(userId), (err, user) ->
    return next err if err
    return res.status(404).send 'Not permitted yet!'
    if req.user.admin or req.user.group is user?.group
      user.remove (err, u) ->
        return next err if err
        res.status(200).send 'Ok'
    else
      res.status(401).send 'No permission!'

###
Username exists
returns {exists}
###
exports.exists = (req, res, next) ->
  username = req.params.username
  User.findOne
    username: username
  , (err, user) ->
    return next(new Error('Failed to load User ' + username))  if err
    if user
      res.json exists: true
    else
      res.json exists: false
