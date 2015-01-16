"use strict"

_ = require 'lodash'
mongoose = require 'mongoose'
cache = require 'memory-cache'

dateToString = require("./util").dateToString
stringToDate = require("./util").stringToDate
Schema = mongoose.Schema

exports = module.exports = (dbprefix) ->

  cached = cache.get("#{dbprefix}.error") or do ->

    ProductErrorFeatureSchema = new Schema(
        product: String
        version: String
        created_at: Date
        errorfeatures: Object
      ,
        collection: "#{dbprefix}.producterrorfeatures"
        _id: false
    )
    ProductErrorFeatureSchema.index {product: 1, version: -1}, {unique: true}
    ProductErrorFeatureSchema.index {created_at: -1}, {expires: '365d'}
    ProductErrorFeatureSchema.methods.getErrorFeatures = (cb=null, page=1, pageSize=10) ->
      page = 1 if page < 1
      if pageSize > 100
        pageSize = 100

      features = _.sortBy _.map(@errorfeatures or [], (value, key) ->
        id: key
        count: value
      ), (feature) ->
        -feature.count
      total = features.length
      if pageSize > 0
        features = features[(page-1)*pageSize...page*pageSize]
      else
        page = 1
        pageSize = total
      ErrorFeature = @model("#{dbprefix}.ErrorFeature")
      Ticket = @model("#{dbprefix}.Ticket")
      results =
        product: @product
        version: @version
        total: total
        page: page
        pageSize: pageSize
        pages: Math.ceil total/pageSize
        data: []

      _.reduce(features, (memo, feature) ->
        if memo is null
          memo = new mongoose.Promise
          memo.fulfill results
        memo.then (results) ->
          p = new mongoose.Promise
          ErrorFeature.findById(feature.id).exec().then (ef) ->
            results.data.push {
              id: ef._id
              created_at: ef.created_at
              features: ef.features
              tag: ef.tag
              count: feature.count
            }
            Ticket.find({errorfeature: feature.id}).exec()
          .then (tickets) ->
            results.data[results.data.length-1].tickets = _.map tickets or [], (t) ->
              id: t._id
              url: t.url
              product: t.product
              created_at: t.created_at
            p.fulfill results
          .end()
          p
      , null).onFulfill (results) ->
        cb(null, results) if cb
      .onReject (err) ->
        cb(err if cb)
      .end()

    # EfforFeature
    ErrorFeatureSchema = new Schema(
        _id: String
        tag: String
        features: Object
        created_at: Date
      ,
        collection: "#{dbprefix}.errorfeatures"
    )

    TicketSchema = new Schema(
        _id: String
        url: String
        product: String
        errorfeature: String
        created_at:
          type: Date
          default: Date.now
      ,
        collection: "#{dbprefix}.tickets"
    )
    TicketSchema.index {errorfeature: 1}
    TicketSchema.index {created_at: -1}, {expires: '365d'}

    ErrorFeature: mongoose.model("#{dbprefix}.ErrorFeature", ErrorFeatureSchema)
    ProductErrorFeature: mongoose.model("#{dbprefix}.ProductErrorFeature", ProductErrorFeatureSchema)
    Ticket: mongoose.model("#{dbprefix}.Ticket", TicketSchema)

  cache.put "#{dbprefix}.error", cached

  cached
