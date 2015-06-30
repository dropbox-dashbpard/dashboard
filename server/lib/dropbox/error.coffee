'use strict'

_ = require 'lodash'
mongoose = require 'mongoose'

exports.getErrorFeatures = (req, res, next) ->
  product = req.param('product')
  version = req.param('version')
  page = Number(req.param('page') or 1)
  pageSize = Number(req.param('pageSize') or 10)
  if product? and version?
    req.model.ProductErrorFeature.findOne {product: product, version: version}, (err, pef) ->
      return next(err) if err?
      if pef
        pef.getErrorFeatures (err, results) ->
          if err?
            next err
          else
            res.json results
        , page, pageSize
      else
        res.json
          product: product
          version: version
          total: 0
          page: page
          pageSize: pageSize
          pages: 0
          data: []

  else
    res.send 400

exports.getErrorFeature = (req, res, next) ->
  req.model.ErrorFeature.findById req.param('errorfeature'), (err, ef) ->
    return next(err) if err?
    if ef
      res.json ef.toJson()
    else
      res.sendStatus(404)

exports.addTicket = (req, res, next) ->
  new req.model.Ticket(
    _id: req.param('_id') or req.param('id') or req.param('ticket')
    url: req.param('url')
    product: req.param('product')
    errorfeature: req.param('errorfeature')
    status: req.param('status') or 'open'
  ).save (err, ticket) ->
    return next err if err?
    res.json ticket

exports.updateTicket = (req, res, next) ->
  id = req.params.ticket
  status = req.params.status
  if status not in ["open", "committed", "resolved", "closed"]
    return res.status(400).send()
  req.model.Ticket.findByIdAndUpdate(id,
    $set:
      status: status
  ).exec().then (ticket) ->
    res.json ticket
  , (err) ->
    next err

exports.queryTickets = (req, res, next) ->
  query = req.model.Ticket.find()
  if req.param('product')
    query = query.where('product').equals req.param('product')
  if req.param('errorfeature')
    query = query.where('errorfeature').equals req.param('errorfeature')
  query.sort("-created_at")
  .limit(Number(req.param('limit')) or 10)
  .exec (err, tickets) ->
    return next err if err?
    res.json data: _.map tickets, (ticket) ->
      ticket.toJson()
