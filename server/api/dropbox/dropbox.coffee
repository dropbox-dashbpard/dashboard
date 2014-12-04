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
    ProductConfig.findOneAndUpdate {
      _id: prod.name
    }, {
      $setOnInsert: {
        display: prod.name,
        template: dc.template,
        limits: dc.limits
        versions: dc.versions
        ignores: dc.ignores
      }
    }, {
      upsert: true
    }, (err, config) ->
      return next(err) if err
      req.product = config
      req.version = config.version req.ua
      config.addVersion 'development', req.version  # TODO debug only
      next()

exports.device = (req, res, next) ->
  total = _.reduce req.body.data, (memo, entry) ->
    memo + (entry.data?.count or 1)
  , 0
  device_id = req.product.device_id req.ua
  DeviceStat.addDevice device_id, req.version, req.report_at, total, (err, device, key) ->
    return next(err) if err
    req.device = device
    req.isNewDevice = device.counter[key] <= total
    if req.device.in_black
      res.status(403).send 'Forbidden!'  # drop all entries in black_list, and don't count it on dropbox summary
    else
      next()

exports.add = (req, res, next) ->
  isUnderLimits = (kvs) ->  # 判断是否超出上报限额
    promise = new mongoose.Promise
    promise.fulfill true
    _.reduce kvs, (memo, limit) ->
      memo.then((underLimit) ->
        p = new mongoose.Promise
        if underLimit
          DropboxLimit.findById limit.key, (err, doc) ->
            if err
              p.error err
            else
              p.fulfill (doc?.value or 0) < (doc?.limit or limit.limit)
        else
          p.fulfill false
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
    promise.fulfill []
    _.reduce entries, (memo, entry) ->
      # 不在黑名单的都会增加dropbox计数
      memo.then (results) ->
        p = new mongoose.Promise
        if req.device.in_white  # 在白名单，所以不增加limit里的计数
          Dropbox.create entry, (err, doc) ->
            results.push if err then null else {dropbox_id: doc._id, result: "ok"}
            p.fulfill results
        else
          kvs = req.product.limit_kvs entry
          isUnderLimits(kvs).then (underLimit) ->  # 判断是否limit计数超限
            if underLimit  # 没有超过limit计数
              Dropbox.create entry, (err, doc) ->
                results.push if err then null else {dropbox_id: doc._id, result: "ok"}
                p.fulfill results
                incLimits kvs  # 增加limit计数
            else  # over limit, so drop it
              results.push null
              p.fulfill results
        p
    , promise

  # 统计计数
  DropboxStat.addDropboxEntry req.product.name, req.version, req.report_at, entries, req.isNewDevice, req.product
  # 纪录dropbox数据
  addEntries(entries).then (results) ->
    res.json data: results
  , (err) ->
    res.status(500).send "Internal server error!"

# update dropbox message content
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

# upload attachment of dropbox
exports.upload = (req, res, next) ->
  dropbox_id = req.param('dropbox_id')
  res.send "TODO"  #TODO upload log file

exports.get = (req, res, next) ->  # get a dropbox entry
  dropbox_id = req.param('dropbox_id')
  Dropbox.findById(dropbox_id).exec()
  .then (doc) ->
      res.json doc
    , (err) ->
      next err

# 查询dropbox列表
exports.list = (req, res) ->  # query dropbox entries
  limit = parseInt(req.param("limit")) or 1000
  from = new Date(req.param("from") or (Date.now() - 1000*3600*24))
  to = new Date(req.param("to") or Date.now())
  if from > to
    [from, to] = [to, from]
  promise = if(deviceId = req.param("device_id"))
    Dropbox.findByDeviceID deviceId, from, to, limit
  else if(app = req.param("app"))
    Dropbox.findAppInAdvance req.param("product"), req.param("version"), app, from, to, limit
  else if(tag = req.param("tag"))
    Dropbox.findTagInAdvance req.param("product"), req.param("version"), tag, from, to, limit
  else if(mac = req.param("mac"))
    Dropbox.findByMacAddress mac, from, to, limit
  else
    Dropbox.findByCreatedAt from, to, limit
  promise.onResolve (err, docs) ->
    res.json(data: docs or [])

# 趋势图
exports.trend = (req, res, next) ->
  product = req.param 'product'
  dist = req.param('dist') or 'production'
  end = if req.param('end') then new Date(req.param('end')) else new Date()
  if req.param('start')
    start = new Date(req.param('start'))
  else
    start = new Date(Date.UTC(end.getUTCFullYear(), end.getUTCMonth(), end.getUTCDate() - 30))
  DropboxStat.trend product, dist, start, end, (err, data) ->
    return next err if err
    res.json 200, {
      product: product
      dist: dist
      start: start
      end: end
      data: data
    }

# 分布图
exports.distribution = (req, res, next) ->
  product = req.param 'product'
  dist = req.param('dist') or 'production'
  end = if req.param("end") then new Date(req.param('end')) else new Date()
  if req.param('start')
    start = new Date(req.param('start'))
  else
    start = new Date(Date.UTC(end.getUTCFullYear(), end.getUTCMonth(), end.getUTCDate() - 30))
  switch req.param("category")
    when "tag"
      distFunc = DropboxStat.tagDistribution
    when "app"
      distFunc = DropboxStat.appDistribution
    else
      return res.send 404
  distFunc.call DropboxStat, product, dist, start, end, (err, data) ->
    return next err if err
    res.json 200, {
      product: product
      dist: dist
      start: start
      end: end
      data: data
    }

exports.errorRate = (req, res, next) ->
  product = req.param 'product'
  dist = req.param('dist') or 'production'
  total = parseInt(req.param('total')) or 12
  drilldown = if req.param("drilldown") then true else false
  DropboxStat.errorRate product, dist, total, drilldown, (err, data) ->
    return next err if err
    res.json 200, {
      product: product
      dist: dist
      total: total
      data: data
    }

exports.errorRateOfApp = (req, res, next) ->
  product = req.param 'product'
  dist = req.param('dist') or 'production'
  total = parseInt(req.param('total')) or 12
  app = req.params[0]
  DropboxStat.errorRateOfApp product, dist, app, total, (err, data) ->
    return next err if err
    res.json 200, {
      product: product
      dist: dist
      total: total
      app: app
      data: data
    }

exports.errorRateOfTag = (req, res, next) ->
  product = req.param 'product'
  dist = req.param('dist') or 'production'
  total = parseInt(req.param('total')) or 12
  tag = req.params[0]
  DropboxStat.errorRateOfTag product, dist, tag, total, (err, data) ->
    return next err if err
    res.json 200, {
      product: product
      dist: dist
      total: total
      tag: tag
      data: data
    }

exports.trendOfVersion = (req, res, next) ->
  product = req.param 'product'
  end = if req.param('end') then new Date(req.param('end')) else new Date()
  if req.param('start')
    start = new Date(req.param('start'))
  else
    start = new Date(Date.UTC(end.getFullYear(), end.getMonth(), end.getDate() - 30))
  ver = req.param('version')
  DropboxStat.trendOfVersion product, ver, start, end, (err, data) ->
    return next err if err
    res.json 200, {
      product: product
      version: ver
      start: start
      end: end
      data: data
    }

exports.distributionOfVersion = (req, res, next) ->
  product = req.param 'product'
  ver = req.param 'version'
  distFun = switch req.param("category")
    when "tag"
      DropboxStat.tagDistributionOfVersion
    when "app"
      DropboxStat.appDistributionOfVersion
    else
      null
  if distFun
    distFun.call DropboxStat, product, ver, (err, data) ->
      return next err if err
      res.json 200, {
        product: product
        version: ver
        data: data
      }
  else
    res.send 404

exports.errorRateOfVersion = (req, res, next) ->
  product = req.param 'product'
  ver = req.param 'version'
  DropboxStat.errorRateOfVersion product, ver, (err, data) ->
    return next err if err
    res.json 200, {
      product: product
      version: ver
      data: data
    }

exports.apps = (req, res, next) ->
  product = req.param 'product'
  ver = req.param 'version'
  DropboxStat.apps product, ver, (err, data) ->
    return next err if err
    res.json 200, {
      product: product
      version: ver
      data: data
    }

exports.tags = (req, res) ->
  product = req.param 'product'
  ver = req.param 'version'
  DropboxStat.tags product, ver, (err, data) ->
    return next err if err
    res.json 200, {
      product: product
      version: ver
      data: data
    }

# 产品列表清单
exports.products = (req, res, next) ->
  ProductConfig.find({}, 'display').exec (err, docs) ->
    return next err if err
    products = _.map docs, (config) ->
      display: config.display
      name: config.name
    res.json 200, data: products

# 产品详单
exports.product = (req, res, next) ->
  product = req.param 'product'
  ProductConfig.findById(product).exec (err, config) ->
    return next err if err
    res.json 200, config
