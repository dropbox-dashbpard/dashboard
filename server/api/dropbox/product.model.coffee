'use strict'

mongoose = require 'mongoose'
_ = require 'lodash'
ejs = require 'ejs'

Schema = mongoose.Schema

# map brand/board/device/product/model in ua string to a specific product name
ProductSchema = new Schema(
  name:
    type: String
    required: true
  build:
    brand: String
    device: String
    product: String
    model: String
)

ProductSchema.index {builds: 1}

ProductConfigSchema = new Schema(
  _id: String
  display: String
  template:
    type: Object
    default:
      version: '<%= build_id %>'
      device_id: '<%= sn %>'
      version_validation: /^\d+\.\d+$/
  versions:
    production: Array  # 产品正式发布版本
    stable: Array  # 稳定版本，类似于weekly stable build
    development: Array  # 开发版本，可以使daily build
  ignores:
    type: Array
    default: [
      {
        app: 'system'
        tag: 'SYSTEM_BOOT'
      }, {
        app: 'system'
        tag: 'SYSTEM_RECOVERY_LOG'
      }
    ]
  limits:
    type: Array
    default: [
      {
        fields: ['product', 'version', 'app', 'tag'],
        limit: 10  # 10 per day
      },
      {
        fields: ['product', 'version'],
        limit: 3000
      }
    ]
)

ProductConfigSchema.virtual('name').get ->
  @_id
ProductConfigSchema.virtual('name').set (value)->
  @_id = value

ProductConfigSchema.methods.limit_kvs = (entry) ->
  _.map @limits, (limit) ->
    key = _.reduce limit.fields, (memo, field) ->
      memo[field] = entry[field]
      memo
    , {}

    key: key
    limit: limit.limit

ProductConfigSchema.methods.shouldIgnore = (app, tag) ->
  _.find @ignores or [], (ig) ->
    if ig.app? and ig.tag?
      ig.app is app and ig.tag is tag
    else if ig.app?
      ig.app is app
    else if ig.tag?
      ig.tag is tag
    else
      false

ProductConfigSchema.methods.addVersion = (type, ver, cb) ->
  if not ver?
    [type, ver] = ["development", type]
  if ver not instanceof Array
    ver = [ver]
  ver = _.filter ver, (v) =>
    @template.version_validation.exec v
  @versions[type] = _.sortBy _.union(@versions[type] or [], ver)
  promise = @save()
  if cb then promose.onResolve(cb) else promise

ProductConfigSchema.methods.device_id = (ua) ->
  ejs.render @template.device_id, ua

ProductConfigSchema.methods.version = (ua) ->
  ejs.render @template.version, ua

exports = module.exports =
  Product: mongoose.model('Product', ProductSchema)
  ProductConfig: mongoose.model('ProductConfig', ProductConfigSchema)
