'use strict'

mongoose = require('mongoose')
_ = require 'lodash'

dateToString = require('./util').dateToString
stringToDate = require('./util').stringToDate

Dropbox = require('./dropbox.model').Dropbox
DropboxLimit = require('./dropbox.model').DropboxLimit
DeviceStat = require('./dropbox.model').DeviceStat
DropboxStat = require('./dropbox.model').DropboxStat

Product = require('./product.model').Product
ProductConfig = require('./product.model').ProductConfig

exports.ua = (req, res, next) ->
  uaString = req.get('X-Dropbox-UA')
  try
    if uaString
      req.ua = _.reduce uaString.split(';'), (memo, s) ->
        [k, v] = s.split '='
        memo[k] = v
        memo
      , {}
      req.ua.ip = req.get('X-Real-IP') or req.get('X-Forwarded-For') or req.ip
      req.report_at = new Date()
      return next()
  catch e
    console.log e
    # TODO mv to logger
  res.status(400).send 'Invalid UA'

exports.product = (req, res, next) ->
  Product.findOne(
    build:
      brand: req.ua.brand
      device: req.ua.device
      product: req.ua.product
      model: req.ua.model
  ).exec (err, prod) ->
    return next(err) if err
    return res.status(404).send 'No such a product!' if not prod
    dc = new ProductConfig()
    ProductConfig.findOneAndUpdate {_id: prod.name}, {$setOnInsert: {display: prod.name, template: dc.template, limits: dc.limits}}, {upsert: true}, (err, config) ->
      return next(err) if err
      req.product = config
      req.version = config.version req.ua
      next()

exports.device = (req, res, next) ->
  total = _.reduce req.body.data, (memo, entry) ->
    memo + (entry.data?.count or 1)
  , 0
  device_id = req.product.device_id req.ua
  DeviceStat.addDevice device_id, req.report_at, total, (err, device, date) ->
    return next(err) if err
    req.device = device
    req.isNewDevice = device.counter[date] <= total
    if req.device.in_black
      res.status(403).send 'Forbidden!'  # drop all entries in black_list, and don't count it on dropbox summary
    else
      next()

exports.add = (req, res, next) ->
  isUnderLimits = (kvs) ->
    promise = new mongoose.Promise
    promise.complete true
    _.reduce kvs, (memo, limit) ->
      memo.then((underLimit) ->
        p = new mongoose.Promise
        if underLimit
          DropboxLimit.findById limit.key, (err, doc) ->
            if err
              p.error err
            else
              p.complete (doc?.value or 0) < (doc?.limit or limit.limit)
        else
          p.complete false
        p
      )
    , promise

  incLimits = (kvs) ->
    _.each kvs, (limit) ->
      DropboxLimit.incLimit limit.key, limit.limit, (err, doc) ->
        console.log err if err

  entries = _.map req.body.data or [], (entry) ->
    entry.product = req.product.name
    entry.version = req.version
    entry.device_id = req.device.device_id
    entry.ua = req.ua
    entry.created_at = req.report_at
    if typeof entry.occurred_at is 'number'
      entry.occurred_at = new Date(entry.occurred_at)
    entry

  addEntries = (entries) ->  # 增加所有的entry, 返回一个promise
    promise = new mongoose.Promise
    promise.complete []
    _.reduce entries, (memo, entry) ->
      # 不在黑名单的都会增加dropbox计数
      memo.then (results) ->
        p = new mongoose.Promise
        if req.device.in_white  # 在白名单，所以不增加limit里的计数
          Dropbox.create entry, (err, doc) ->
            results.push if err then null else {dropbox_id: doc._id, result: "ok"}
            p.complete results
        else
          kvs = req.product.limit_kvs entry
          isUnderLimits(kvs).then (underLimit) ->  # 判断是否limit计数超限
            if underLimit  # 没有超过limit计数
              Dropbox.create entry, (err, doc) ->
                results.push if err then null else {dropbox_id: doc._id, result: "ok"}
                p.complete results
                incLimits kvs  # 增加limit计数
            else  # over limit, so drop it
              results.push null
              p.complete results
        p
    , promise

  # 统计计数
  DropboxStat.addDropboxEntry(req.product.name, req.version, req.report_at, entries, req.isNewDevice)
  # 纪录dropbox数据
  addEntries(entries).then (results) ->
    res.json data: results
  , (err) ->
    res.status(500).send "Internal server error!"

exports.updateContent = (req, res, next) ->
  dropbox_id = req.param('dropbox_id')
  if req.body.content?
    Dropbox.findByIdAndUpdate(dropbox_id, $set: {"data.content": req.body.content}, select: "_id").exec()
    .then (doc) ->
        res.json result: "ok"
      , (err) ->
        next err
  else
    res.status(400).send "No content!"

exports.upload = (req, res, next) ->
  dropbox_id = req.param('dropbox_id')
  res.send "TODO"  #TODO upload log file

exports.get = (req, res, next) ->
  dropbox_id = req.param('dropbox_id')
  Dropbox.findById(dropbox_id).exec()
  .then (doc) ->
      res.json doc
    , (err) ->
      next err
