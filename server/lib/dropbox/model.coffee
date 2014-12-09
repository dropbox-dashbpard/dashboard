'use strict'

_ = require 'lodash'

# Model列表清单
exports.list = (req, res, next) ->
  req.model.Product.find {}, (err, docs) ->
    return next err if err
    res.json docs

# Model详单
exports.get = (req, res, next) ->
  req.model.Product.findById req.param('id'), (err, doc) ->
    return next err if err
    res.json doc

exports.update = (req, res, next) ->
  req.model.Product.findByIdAndUpdate req.param('id'), {
    name: req.param 'name'
    build: req.param 'build'
  }, (err, doc) ->
    return next err if err
    res.json doc

exports.add = (req, res, next) ->
  new req.model.Product(
    name: req.param('name')
    build: req.param('build')
  ).save (err, doc) ->
    return next err if err
    res.json doc

exports.del = (req, res, next) ->
  req.model.Product.findByIdAndRemove req.param('id'), (err) ->
    return next err if err
    res.send 200
