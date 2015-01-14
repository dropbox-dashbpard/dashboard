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
        created_at: Date
      ,
        collection: "#{dbprefix}.tickets"
    )
    TicketSchema.index {error: 1}
    TicketSchema.index {created_at: -1}, {expires: '365d'}

    ErrorFeature: mongoose.model("#{dbprefix}.ErrorFeature", ErrorFeatureSchema)
    ProductErrorFeature: mongoose.model("ProductErrorFeature", ProductErrorFeatureSchema)
    Ticket: mongoose.model("Ticket", TicketSchema)

  cache.put "#{dbprefix}.error", cached

  cached
