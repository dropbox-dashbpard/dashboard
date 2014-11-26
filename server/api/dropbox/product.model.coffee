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

ProductConfigSchema.methods.device_id = (ua) ->
  ejs.render @template.device_id, ua

ProductConfigSchema.methods.version = (ua) ->
  ejs.render @template.version, ua

exports = module.exports =
  Product: mongoose.model('Product', ProductSchema)
  ProductConfig: mongoose.model('ProductConfig', ProductConfigSchema)
