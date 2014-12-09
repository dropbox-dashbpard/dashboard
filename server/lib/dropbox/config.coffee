'use strict'

_ = require 'lodash'

# Model列表清单
exports.list = (req, res, next) ->
  req.model.ProductConfig.find {}, (err, docs) ->
    return next err if err
    res.json docs

# Model详单
exports.get = (req, res, next) ->
  req.model.ProductConfig.findById req.param('id'), (err, doc) ->
    return next err if err
    res.json doc

exports.update = (req, res, next) ->
  op = _.reduce ['display', 'template', 'ignores', 'limits'], (memo, key) ->
    memo.$set[key] = req.param(key) if req.param(key)
    memo
  , $set: {}
  console.log JSON.stringify(op)
  req.model.ProductConfig.findByIdAndUpdate req.param('id'), op, (err, doc) ->
    return next err if err
    res.json doc

exports.add = (req, res, next) ->
  new req.model.ProductConfig(
    name: req.param('name')
    display: req.param('display')
  ).save (err, doc) ->
    return next err if err
    res.json doc

exports.del = (req, res, next) ->
  req.model.ProductConfig.findByIdAndRemove req.param('id'), (err) ->
    return next err if err
    res.send 200
