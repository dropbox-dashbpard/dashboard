'use strict'

# 
# Route middleware to ensure user is authenticated.
# 
exports.ensureAuthenticated = (req, res, next) ->
  return next() if req.isAuthenticated()
  res.send(401)

exports.ensureToken = (req, res, next) ->
  require('passport').authenticate('bearer', session: false)(req, res, next)
