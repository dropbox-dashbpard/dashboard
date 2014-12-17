'use strict'

mongoose = require('mongoose')
crypto = require('crypto')

UserSchema = new mongoose.Schema(
  email:
    type: String
    unique: true
    required: true

  username:
    type: String
    unique: true
    required: true

  hashedPassword: String
  salt: String
  name: String
  admin: Boolean
  guest: Boolean
  provider: String
  group:
    type: String
    required: true
    default: 'default'
,
  collection: 'admin_user'
)

###
Virtuals
###
UserSchema.virtual('password').set((password) ->
  @_password = password
  @salt = @makeSalt()
  @hashedPassword = @encryptPassword(password)
).get ->
  @_password

UserSchema.virtual('user_info').get ->
  _id: @_id
  username: @username
  email: @email
  name: @name
  group: @group
  admin: @admin
  guest: @guest

###
Validations
###
validatePresenceOf = (value) ->
  value and value.length

UserSchema.path('email').validate ((email) ->
  emailRegex = /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/
  emailRegex.test email
), 'The specified email is invalid.'

###
Pre-save hook
###
UserSchema.pre 'save', (next) ->
  return next()  unless @isNew
  unless validatePresenceOf(@password)
    next new Error('Invalid password')
  else
    next()

###
Methods
###
UserSchema.methods =
  ###*
  Authenticate - check if the passwords are the same
  ###
  authenticate: (plainText) ->
    @encryptPassword(plainText) is @hashedPassword
  
  ###*
  Make salt
  ###
  makeSalt: ->
    crypto.randomBytes(16).toString 'base64'

  ###*
  Encrypt password
  ###
  encryptPassword: (password) ->
    return ''  if not password or not @salt
    salt = new Buffer(@salt, 'base64')
    crypto.pbkdf2Sync(password, salt, 10000, 64).toString 'base64'

GroupSchema = new mongoose.Schema(
  _id: String
  token: String
,
  collection: 'admin_group'
)

GroupSchema.index token: 1

GroupSchema.virtual('name').set((name) ->
  @_id = name
).get ->
  @_id

exports = module.exports =
  User: mongoose.model 'User', UserSchema
  UserGroup: mongoose.model 'UserGroup', GroupSchema
