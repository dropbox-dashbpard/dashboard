'use strict'

_ = require 'lodash'
cache = require 'memory-cache'

getProductList = (prefix, ProductConfig, callback) ->
  key = "#{prefix}:products"
  value = cache.get(key)
  if value?
    return callback null, value

  ProductConfig.find().sort("_id").exec (err, docs) ->
    return callback err if err?
    products = _.map docs, (config) ->
      display: config.display or config.name
      name: config.name
      versions: config.versions
      versionTypes: config.versionTypes
      template: config.template
      ignores: config.ignores
      limits: config.limits

    cache.put key, products, 1000*60
    callback null, products

# 产品列表清单
exports.list = (req, res, next) ->
  getProductList req.prefix, req.model.ProductConfig, (err, products) ->
    return next err if err?
    res.json data: products

# 产品详单
exports.get = (req, res, next) ->
  product = req.param 'product'
  req.model.ProductConfig.findById(product).exec (err, config) ->
    return next err if err
    return res.sendStatus 404 if not config?
    config.builds (err, builds) ->
      return next err if err
      config = JSON.parse JSON.stringify(config)
      config.builds = builds
      config.name = config._id
      res.json config

# 更改产品版本号
exports.updateVersions = (req, res, next) ->
  product = req.param 'product'
  dist = req.param 'dist'
  version = req.param('version') or req.param('versions')
  req.model.ProductConfig.findById(product).exec (err, config) ->
    return next err if err
    return res.sendStatus 404 if not config?
    config.addVersion dist, version, (err, doc) ->
      return next err if err
      res.json doc

# list产品版本号
exports.getVersions = (req, res, next) ->
  product = req.param 'product'
  req.model.ProductConfig.findById(product).exec (err, config) ->
    return next err if err
    return res.sendStatus(404) if not config?
    res.json versions: config.versions or {}

# 删除产品版本号
exports.rmVersion = (req, res, next) ->
  product = req.param 'product'
  dist = req.param 'dist'
  version = req.param 'version'
  req.model.ProductConfig.findById(product).exec (err, config) ->
    return next err if err
    return res.sendStatus 404 if not config?
    config.set "versions.#{dist}", _.filter(config.versions[dist] or [], (ver) -> ver is not version)
    config.save (err, doc) ->
      return next err if err
      res.json doc
