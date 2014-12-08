###
Populate DB with sample data on server start
to disable, edit config/environment/index.js, and set `seedDB: false`
###
"use strict"

User = require('../lib/auth/user.model').User
UserGroup = require('../lib/auth/user.model').UserGroup

UserGroup.find({}).remove ->
  new UserGroup(
    name: 'test'
    token: '068772F3-8130-44C0-ADBB-511C68DA2888'
  ).save (err, group) ->

User.find({}).remove ->
  new User(
    email: 'admin@test.com'
    username: 'admin'
    password: 'admin'
    admin: true
    group: 'default'
  ).save (err, doc)->

  new User(
    email: 'guest@test.com'
    username: 'guest'
    password: 'guest'
    group: 'default'
  ).save (err, doc)->

  new User(
    email: 'test@test.com'
    username: 'test'
    password: 'test'
    group: 'test'
  ).save (err, doc)->
