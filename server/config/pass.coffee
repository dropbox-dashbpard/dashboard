'use strict';

mongoose = require('mongoose')
passport = require('passport')
LocalStrategy = require('passport-local').Strategy
BearerStrategy = require('passport-http-bearer').Strategy
cache = require 'memory-cache'

User = require('../lib/auth/user.model').User
UserGroup = require('../lib/auth/user.model').UserGroup

module.exports = (app) ->

  # Serialize sessions
  passport.serializeUser (user, done) ->
    done(null, user.id)

  passport.deserializeUser (id, done) ->
    User.findOne _id: id, (err, user) ->
      done(err, user)

  # Use local strategy
  passport.use new LocalStrategy(
      usernameField: 'email'
      passwordField: 'password'
    , (email, password, done) ->
      User.findOne email: email, (err, user) ->
        return done err if (err)
        unless user
          return done null, false, {
            errors:
              email:
                type: 'Email is not registered.'
          }
        unless user.underlimit()
          return done null, false, {
            errors:
              password:
                type: 'Reach max error login.'
          }
        unless user.authenticate(password)
          User.incErrorCnt email
          return done null, false, {
            errors:
              password:
                type: 'Password is incorrect.'
          }
        User.clearErrorCnt email
        return done(null, user)
    )

  passport.use new BearerStrategy((token, done) ->
    key = token
    value = cache.get(key)
    if value?
      return done null, value

    UserGroup.findOne {token: token}, (err, group) ->
      return done(err, false) if err
      if group?
        done null, group
        cache.put key, group, 60*1000
      else
        done "Not found!", false
  )

  app.use passport.initialize()
  app.use passport.session()
