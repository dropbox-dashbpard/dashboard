"use strict"

mongoose = require("mongoose")
_ = require "lodash"

dateToString = require("./util").dateToString
stringToDate = require("./util").stringToDate
Schema = mongoose.Schema

##################################################################################
# Dropbox message
DropboxSchema = new Schema(
  created_at:
    type: Date
    default: Date.now
    expires: '180d'  # expires after 180 days
  occurred_at: Date
  device_id: String
  product: String  # android product name
  version: String  # sw version of android product
  app: String  # application or process name
  tag: String  # dropbox tag
  data: Object  # detailed data of dropbox message
  attachment: Array  # URL list of binary attachment
  ua: Object  # UA object
)

DropboxSchema.index {device_id: 1, created_at: -1}
DropboxSchema.index {product: 1, version: 1, app: 1, tag: 1, created_at: -1}

DropboxSchema.statics.findByDeviceID = (deviceId, from_date, to_date, limit, cb) ->
  promise = @find()
  .where("created_at").gte(from_date).lt(to_date)
  .where("device_id").equals(deviceId).limit(limit)
  .select("product version app tag occurred_at created_at device_id")
  .exec()
  if cb then promise.onResolve(cb) else promise

DropboxSchema.statics.findAppInAdvance = (product, version, app, from_date, to_date, limit, cb) ->
  promise = @find()
  .where("created_at").gte(from_date).lt(to_date)
  .where("product").equals(product)
  .where("version").equals(version)
  .where("app").equals(app)
  .limit(limit)
  .select("product version occurred_at device_id tag app").exec()
  if cb then promise.onResolve(cb) else promise

DropboxSchema.statics.findTagInAdvance = (product, version, tag, from_date, to_date, limit, cb) ->
  promise = @find()
  .where("created_at").gte(from_date).lt(to_date)
  .where("product").equals(product)
  .where("version").equals(version)
  .where("tag").equals(tag)
  .limit(limit)
  .select("product version app tag occurred_at created_at device_id")
  .exec()
  if cb then promise.onResolve(cb) else promise

DropboxSchema.statics.findByMacAddress = (mac, from_date, to_date, limit, cb) ->
  promise = @find()
  .where("created_at").gte(from_date).lt(to_date)
  .where("ua.mac_address").equals(mac)
  .limit(limit)
  .select("product version app tag occurred_at created_at device_id")
  .exec()
  if cb then promise.onResolve(cb) else promise

DropboxSchema.statics.findByCreatedAt = (from_date, to_date, limit, cb) ->
  promise = @find()
  .where("created_at").gte(from_date).lt(to_date)
  .limit(limit)
  .select("product version app tag occurred_at created_at device_id")
  .exec()
  if cb then promise.onResolve(cb) else promise

##################################################################################
# define the limitation of dropbox message of every day
DropboxLimitSchema = new Schema(
  created_at:
    type: Date
    default: Date.now
    expires: '1d'  # expires after one day
  _id: Object  # {field:value,field:value,...}"
  limit:
    type: Number
    required: true
  value:
    type: Number
    default: 0
)

DropboxLimitSchema.statics.incLimit = (id, limit, callback) ->
  promise = @findOneAndUpdate(
      _id: id
    ,
      $inc:
        value: 1
      $setOnInsert:
        limit: limit
        created_at: stringToDate(dateToString(new Date()))
    , upsert: true
  ).exec()
  promise.addBack(callback) if callback

DropboxLimitSchema.virtual('key').get ->
  @_id
DropboxLimitSchema.virtual('key').set (value)->
  @_id = value

##################################################################################
# the device counter of every day
DeviceStatSchema = new Schema(
  _id: String  # device_id
  counter: Object  # {"20141110": 12, "20141111": 9, ...}
  in_white:
    type: Boolean
    default: false
  in_black:
    type: Boolean
    default: false
)

DeviceStatSchema.virtual('device_id').get ->
  @_id
DeviceStatSchema.virtual('device_id').set (value)->
  @_id = value

DeviceStatSchema.statics.addDevice = (device_id, date, count, callback) ->
  date = dateToString(date)
  op = $inc: {}
  op.$inc["counter.#{date}"] = count
  @findByIdAndUpdate device_id, op, {upsert: true, select: "counter.#{date} in_black in_white"}, (err, doc) ->
    return callback(err) if err
    callback null, doc, date

##################################################################################
# counter of product/version/date/app/tag
DropboxStatSchema = new Schema(
  product: String
  version: String
  date: String  # "yyyymmdd", e.g. "20141122"
  all:
    type: Object
    default:
      devices: 0
      occurs: 0
  app: Object
  tag: Object
)

DropboxStatSchema.index {date: -1}
DropboxStatSchema.index {date: -1, product: 1, version: -1}
DropboxStatSchema.index {product: 1, version: -1}

DropboxStatSchema.statics.toKey = (name) ->
  name.replace /\./g, "#"

DropboxStatSchema.statics.toName = (key) ->
  key.replace /#/g, '.'

DropboxStatSchema.statics.addDropboxEntry = (product, version, date, entries, newDevice, callback) ->
  doc = $inc: {}
  doc.$inc["all.devices"] = 1 if newDevice
  total = 0
  _.each entries, (entry) =>
    [app, tag, count] = [@toKey(entry.app), @toKey(entry.tag), entry.data?.count or 1]
    if doc.$inc["app.#{app}.occurs"]?
      doc.$inc["app.#{app}.occurs"] += count
    else
      doc.$inc["app.#{app}.occurs"] = count
    doc.$inc["app.#{app}.devices"] = 1 if newDevice
    if doc.$inc["app.#{app}.tag.#{tag}.occurs"]?
      doc.$inc["app.#{app}.tag.#{tag}.occurs"] += count
    else
      doc.$inc["app.#{app}.tag.#{tag}.occurs"] = count
    doc.$inc["app.#{app}.tag.#{tag}.devices"] = 1 if newDevice
    if doc.$inc["tag.#{tag}.occurs"]?
      doc.$inc["tag.#{tag}.occurs"] += count
    else
      doc.$inc["tag.#{tag}.occurs"] = count
    doc.$inc["tag.#{tag}.devices"] = 1 if newDevice
    total += count
  doc.$inc["all.occurs"] = total
  promise = @findOneAndUpdate({
      product: product
      version: version
      date: dateToString date
    }, doc, upsert: true
  ).select("_id").exec()
  promise.addBack(callback) if callback

# exports
exports = module.exports =
  Dropbox: mongoose.model("Dropbox", DropboxSchema)
  DropboxLimit: mongoose.model("DropboxLimit", DropboxLimitSchema)
  DeviceStat: mongoose.model("DeviceStat", DeviceStatSchema)
  DropboxStat: mongoose.model("DropboxStat", DropboxStatSchema)
