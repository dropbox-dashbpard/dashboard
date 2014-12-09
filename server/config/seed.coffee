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

  new UserGroup(
    name: 'default'
    token: 'D58F569C-4A34-451D-BD01-F08D462136C7'
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
    email: 'guest@guest.com'
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

model = require('../lib/dropbox/product.model')('test')

model.Product.find({}).remove ->
  new model.Product(
    name: 'alps'
    build:
      brand: 'Android'
      device: 'hammerhead'
      product: 'alps'
      model: 'AOSP on HammerHead'
  ).save (err, doc) ->

model.ProductConfig.find({}).remove ->
  new model.ProductConfig(
    name: 'alps'
    display: '阿尔卑斯'
  ).save (err, doc) ->
