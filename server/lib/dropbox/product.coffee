'use strict'

_ = require 'lodash'

# 产品列表清单
exports.list = (req, res, next) ->
  req.model.ProductConfig.find({}, 'display').exec (err, docs) ->
    return next err if err
    products = _.map docs, (config) ->
      display: config.display or config.name
      name: config.name
    res.json data: products

# 产品详单
exports.get = (req, res, next) ->
  product = req.param 'product'
  req.model.ProductConfig.findById(product).exec (err, config) ->
    return next err if err
    return res.res.sendStatus 404 if not config?
    config.builds (err, builds) ->
      return next err if err
      config = JSON.parse JSON.stringify(config)
      config.builds = builds
      res.json config

# 产品版本类型
exports.versionType = (req, res, next) ->
  res.json
    data:
      production: "产品发布（最终用户）"
      stable: "稳定发布（内测用户）"
      development: "开发版本（工程测试）"
