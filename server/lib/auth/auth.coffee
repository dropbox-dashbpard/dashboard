'use strict'

# 
# Route middleware to ensure user is authenticated.
# 
exports.ensureAuthenticated = (req, res, next) ->
  return next() if req.isAuthenticated()
  res.sendStatus(401)

exports.ensureToken = (req, res, next) ->
  return next() if req.isAuthenticated()
  require('passport').authenticate('bearer', session: false)(req, res, next)

exports.ensureGroupAdmin = (req, res, next) ->
  if req.user.admin
    next()
  else if req.user.guest
    res.sendStatus(401)
  else
    next()
