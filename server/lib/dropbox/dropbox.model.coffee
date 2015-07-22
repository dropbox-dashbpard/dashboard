"use strict"

_ = require 'lodash'
mongoose = require 'mongoose'
cache = require 'memory-cache'

dateToString = require("./util").dateToString
stringToDate = require("./util").stringToDate
Schema = mongoose.Schema

IpCache = require '../util/ip.model'

exports = module.exports = (dbprefix) ->

  cached = cache.get("#{dbprefix}.dropbox") or do ->
    ##################################################################################
    # Dropbox message
    DropboxSchema = new Schema(
      created_at:
        type: Date
        default: Date.now
        expires: '60d'  # expires after 180 days
      occurred_at: Date
      device_id: String
      product: String  # android product name
      version: String  # sw version of android product
      app: String  # application or process name
      tag: String  # dropbox tag
      data: Object  # detailed data of dropbox message
      attachment: Array  # URL list of binary attachment
      ua: Object  # UA object
      errorfeature: String  # errorfeature id
    ,
      collection: "#{dbprefix}.dropboxes"
    )

    DropboxSchema.index {device_id: 1, created_at: -1}
    DropboxSchema.index {product: 1, version: 1, app: 1, tag: 1, created_at: -1}
    DropboxSchema.index {product: 1, errorfeature: 1, created_at: -1}

    DropboxSchema.statics.findByDeviceID = (deviceId, from_date, to_date, limit, cb) ->
      promise = @find()
      .where("created_at").gte(from_date).lt(to_date)
      .where("device_id").equals(deviceId)
      .sort('-created_at')
      .limit(limit)
      .select("product version occurred_at app tag created_at device_id errorfeature")
      .exec()
      if cb then promise.onResolve(cb) else promise

    DropboxSchema.statics.findByErrorFeature = (product, errorfeature, from_date, to_date, limit, cb) ->
      promise = @find()
      .where("created_at").gte(from_date).lt(to_date)
      .where("product").equals(product)
      .where("errorfeature").equals(errorfeature)
      .sort('-created_at')
      .limit(limit)
      .select("product version occurred_at app tag created_at device_id errorfeature")
      .exec()
      if cb then promise.onResolve(cb) else promise

    DropboxSchema.statics.findByAppInAdvance = (product, version, app, from_date, to_date, limit, cb) ->
      promise = @find()
      .where("created_at").gte(from_date).lt(to_date)
      .where("product").equals(product)
      .where("version").equals(version)
      .where("app").equals(app)
      .sort('-created_at')
      .limit(limit)
      .select("product version occurred_at app tag created_at device_id errorfeature")
      .exec()
      if cb then promise.onResolve(cb) else promise

    DropboxSchema.statics.findByTagInAdvance = (product, version, tag, from_date, to_date, limit, cb) ->
      promise = @find()
      .where("created_at").gte(from_date).lt(to_date)
      .where("product").equals(product)
      .where("version").equals(version)
      .where("tag").equals(tag)
      .sort('-created_at')
      .limit(limit)
      .select("product version occurred_at app tag created_at device_id errorfeature")
      .exec()
      if cb then promise.onResolve(cb) else promise

    DropboxSchema.statics.findByMacAddress = (mac, from_date, to_date, limit, cb) ->
      promise = @find()
      .where("created_at").gte(from_date).lt(to_date)
      .where("ua.mac_address").equals(mac)
      .sort('-created_at')
      .limit(limit)
      .select("product version occurred_at app tag created_at device_id errorfeature")
      .exec()
      if cb then promise.onResolve(cb) else promise

    DropboxSchema.statics.findByImei = (imei, from_date, to_date, limit, cb) ->
      promise = @find()
      .where("created_at").gte(from_date).lt(to_date)
      .where("ua.imei").equals(imei)
      .sort('-created_at')
      .limit(limit)
      .select("product version occurred_at app tag created_at device_id errorfeature")
      .exec()
      if cb then promise.onResolve(cb) else promise

    DropboxSchema.statics.findByCreatedAt = (from_date, to_date, limit, cb) ->
      promise = @find()
      .where("created_at").gte(from_date).lt(to_date)
      .sort('-created_at')
      .limit(limit)
      .select("product version occurred_at app tag created_at device_id errorfeature")
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
    ,
      collection: "#{dbprefix}.dropboxlimits"
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
      if callback then promise.onResolve(callback) else promise

    DropboxLimitSchema.virtual('key').get ->
      @_id
    DropboxLimitSchema.virtual('key').set (value)->
      @_id = value

    ##################################################################################
    # the device counter of every day
    DeviceStatSchema = new Schema(
      _id: String  # device_id
      counter: Object  # {"20141110|version": 12, "20141111|version": 9, ...} 用来计算上报次数
      error: Object # {"20141110": 12}, 用来计算错误总数
      product: String
      in_white:
        type: Boolean
        default: false
      in_black:
        type: Boolean
        default: false
    ,
      collection: "#{dbprefix}.devicestats"
    )

    DeviceStatSchema.virtual('device_id').get ->
      @_id
    DeviceStatSchema.virtual('device_id').set (value)->
      @_id = value

    DeviceStatSchema.statics.addDevice = (device_id, product, version, date, count, callback) ->
      date = dateToString(date)
      key = "#{date}|#{version}".replace /\./g, "#"
      op = $inc: {}
      if count > 0
        op.$inc["error.#{date}"] = count
      op.$inc["counter.#{key}"] = 1
      op.$set = product: product
      @findByIdAndUpdate device_id, op, {upsert: true, select: "counter.#{key} in_black in_white"}, (err, doc) ->
        return callback(err) if err
        callback null, doc, key

    ##################################################################################
    # the location counter of every day
    LocationStatSchema = new Schema(
      date: String  # "yyyymmdd", e.g. "20141122"
      product: String
      total: Number
      country: Object
      province: Object
      city: Object
    ,
      collection: "#{dbprefix}.locationstats"
    )

    LocationStatSchema.index {date: -1, product: 1}

    LocationStatSchema.statics.addIp = (ip, product, date) ->
      IpCache.location ip, (err, location) =>
        return if err?
        op = $inc: {total: 1}
        if location.country != "未分配或者内网IP"
          op.$inc["#{field}.#{location[field]}"] = 1 for field in ['country', 'province', 'city'] when location[field]
        @findOneAndUpdate({date: dateToString(date or new Date), product: product}, op, {upsert: true}).exec()

    LocationStatSchema.statics.locationDistribution = (days, product, callback) ->
      days = Number(days)
      timestamp = new Date().getTime()
      end = dateToString new Date(timestamp)
      start = dateToString new Date(timestamp - (days - 1)*1000*3600*24)
      query = @find().where('date').gte(start).lte(end)
      if product?
        query = query.where('product').equals(product)
      query.exec().then (stats) ->
        summary = _.reduce stats, (result, stat) ->
          result.total += stat.total
          for field in ['country', 'province', 'city']
            for key of stat[field] or {}
              result[field][key] ?= 0
              result[field][key] += stat[field][key]
          result
        , {
          total: 0
          country: {}
          province: {}
          city: {}
        }

        total = summary.total
        result = {total: total}
        for field in ['country', 'province', 'city']
          result[field] = _.map _.sortBy([k, v] for k, v of summary[field] or {}, (item) ->
            -item[1]
          ), (item) ->
            name: item[0]
            percent: item[1]/total
        callback null, result
      , (err) ->
        callback err

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
          occurred: 0
      app: Object
      tag: Object
    ,
      collection: "#{dbprefix}.dropboxstats"
    )

    DropboxStatSchema.index {date: -1}
    DropboxStatSchema.index {date: -1, product: 1, version: -1}
    DropboxStatSchema.index {product: 1, version: -1}

    DropboxStatSchema.statics.toKey = (name) ->
      name.replace /\./g, "#"

    DropboxStatSchema.statics.toName = (key) ->
      key.replace /#/g, '.'

    DropboxStatSchema.virtual('apps').get ->
      for app of @app
        @model("#{dbprefix}.DropboxStat").toName(app)

    DropboxStatSchema.virtual('tags').get ->
      for tag of @tag
        @model("#{dbprefix}.DropboxStat").toName(tag)

    DropboxStatSchema.statics.addDropboxEntry = (product, version, date, entries, newDevice, config, callback) ->
      doc = $inc: {}
      total = 0
      _.each entries, (entry) =>
        [app, tag, count] = if config.shouldIgnore(entry.app, entry.tag)  # ignore
           [@toKey(entry.app), @toKey(entry.tag), 0]
        else  # not ignore
          [@toKey(entry.app), @toKey(entry.tag), entry.data?.count or 1]

        if doc.$inc["app.#{app}.occurred"]?
          doc.$inc["app.#{app}.occurred"] += count
        else
          doc.$inc["app.#{app}.occurred"] = count
        doc.$inc["app.#{app}.devices"] = 1 if newDevice
        if doc.$inc["app.#{app}.tag.#{tag}.occurred"]?
          doc.$inc["app.#{app}.tag.#{tag}.occurred"] += count
        else
          doc.$inc["app.#{app}.tag.#{tag}.occurred"] = count
        doc.$inc["app.#{app}.tag.#{tag}.devices"] = 1 if newDevice
        if doc.$inc["tag.#{tag}.occurred"]?
          doc.$inc["tag.#{tag}.occurred"] += count
        else
          doc.$inc["tag.#{tag}.occurred"] = count
        doc.$inc["tag.#{tag}.devices"] = 1 if newDevice
        total += count
      doc.$inc["all.occurred"] = total
      doc.$inc["all.devices"] = 1 if newDevice
      @findOneAndUpdate({
          product: product
          version: version
          date: dateToString date
        }, doc, upsert: true
      ).select("_id")
      .exec()
      .then (stat) =>
        p = @findOneAndUpdate({
            product: product
            version: version
            date: null
          }, doc, upsert: true
        ).select("_id").exec()
        if callback then p.onResolve(callback) else p
      , (err) ->
        callback err if callback

    # 计算特定产品和build类型的错误趋势
    DropboxStatSchema.statics.trend = (product, dist, start, end, cb) ->
      if start instanceof Date
        start = dateToString start
      if end instanceof Date
        end = dateToString end
      @model("#{dbprefix}.ProductConfig").findById product, "versions.#{dist}", (err, config) =>
        return cb err if err
        @find()
        .where('date').gte(start).lte(end)
        .where('product').equals(product)
        .where('version').in(config?.versions?[dist] or [])
        .select('version date all').exec (err, docs) =>
          return cb err if err
          result = {}
          startDate = stringToDate start
          while (date = dateToString(startDate)) <= end
            result[date] = occurred: 0, devices: 0
            startDate = new Date(Date.UTC(startDate.getUTCFullYear(), startDate.getUTCMonth(), startDate.getUTCDate() + 1))
          for doc in docs
            result[doc.date].occurred += doc.all.occurred or 0
            result[doc.date].devices += doc.all.devices or 0
          cb null, result

    # 计算特定产品和build类型的按照tag的分布
    DropboxStatSchema.statics.tagDistribution = (product, dist, start, end, cb) ->
      if start instanceof Date
        start = dateToString start
      if end instanceof Date
        end = dateToString end
      @model("#{dbprefix}.ProductConfig").findById product, "versions.#{dist}", (err, config) =>
        return cb err if err
        @find()
        .where('date').gte(start).lte(end)
        .where('product').equals(product)
        .where('version').in(config.versions[dist] or [])
        .select('tag').exec (err, docs) =>
          return cb err if err
          result = {}
          for doc in docs
            for tag, value of doc.tag
              name = @toName tag
              result[name] ?= 0
              result[name] += (value.occurred or 0)
          cb null, result

    # 计算特定产品和build类型的按照tag的分布
    DropboxStatSchema.statics.appDistribution = (product, dist, start, end, cb) ->
      if start instanceof Date
        start = dateToString start
      if end instanceof Date
        end = dateToString end
      @model("#{dbprefix}.ProductConfig").findById product, "versions.#{dist}", (err, config) =>
        return cb err if err
        @find()
        .where('date').gte(start).lte(end)
        .where('product').equals(product)
        .where('version').in(config.versions[dist] or [])
        .select('app').exec (err, docs) =>
          return cb err if err
          result = {}
          for doc in docs
            for app, value of doc.app
              name = @toName app
              result[name] ?= 0
              result[name] += (value.occurred or 0)
          cb null, result

    # 计算特定产品和build类型的错误率
    DropboxStatSchema.statics.errorRate = (product, dist, total, drilldown, cb) ->
      @model("#{dbprefix}.ProductConfig").findById product, "versions.#{dist}", (err, config) =>
        return cb err if err
        versions = (config?.versions?[dist] or [])[-total..]
        @find()
        .where('product').equals(product)
        .where('version').in(versions)
        .where('date').equals(null)
        .select('version all app')
        .exec (err, docs) =>
          return cb err if err
          result = {}
          for doc in docs
            ver = doc.version
            result[ver] ?= occurred: 0, devices: 0, apps: {}
            result[ver].occurred += doc.all?.occurred or 0
            result[ver].devices += doc.all?.devices or 0
            if drilldown
              for app, value of doc.app
                appName = @toName app
                result[ver].apps[appName] ?= 0
                result[ver].apps[appName] += value.occurred
          cb null, ({version: ver, occurred: result[ver]?.occurred or 0, devices: result[ver]?.devices or 0, drilldown: result[ver]?.apps or {}} for ver in versions)

    # 特定产品，应用在不同版本上的错误旅
    DropboxStatSchema.statics.errorRateOfApp = (product, dist, app, total, cb) ->
      @model("#{dbprefix}.ProductConfig").findById product, "versions.#{dist}", (err, config) =>
        versions = (config.versions[dist] or [])[-total..]
        return cb err if err
        @find()
        .where('product').equals(product)
        .where('version').in(versions)
        .where('date').equals(null)
        .select('version app all')
        .exec (err, docs) =>
          return cb err if err
          result = {}
          for ver in versions
            result[ver] = occurred: 0, devices: 0, drilldown: {}
          for doc in docs
            ver = doc.version
            app = @toKey app
            result[ver].devices += doc.all?.devices or 0
            result[ver].occurred += doc.app?[app]?.occurred or 0
            for tag, value of doc.app?[app]?.tag
              result[ver].drilldown[tag] ?= 0
              result[ver].drilldown[tag] += value.occurred or 0
          for ver of result
            delete result[ver].drilldown[k] for k, v of result[ver].drilldown when v is 0
          cb(null, {version: ver, occurred: result[ver].occurred, devices: result[ver].devices, drilldown: result[ver].drilldown} for ver in versions)

    # 特定产品，tag在不同版本上的错误旅
    DropboxStatSchema.statics.errorRateOfTag = (product, dist, tag, total, cb) ->
      @model("#{dbprefix}.ProductConfig").findById product, "versions.#{dist}", (err, config) =>
        versions = (config.versions[dist] or [])[-total..]
        return cb err if err
        @find()
        .where('product').equals(product)
        .where('version').in(versions)
        .where('date').equals(null)
        .select('version tag all')
        .exec (err, docs) =>
          return cb err if err
          result = {}
          for ver in versions
            result[ver] = occurred: 0, devices: 0
          for doc in docs
            ver = doc.version
            tag = @toKey tag
            result[ver].devices += doc.all?.devices or 0
            result[ver].occurred += doc.tag?[tag]?.occurred or 0
          cb(null, {version: ver, occurred: result[ver].occurred, devices: result[ver].devices} for ver in versions)

    # 特定产品和版本的错误趋势
    DropboxStatSchema.statics.trendOfVersion = (product, ver, start, end, cb) ->
      if start instanceof Date
        start = dateToString start
      if end instanceof Date
        end = dateToString end
      @find()
      .where('date').gte(start).lte(end)
      .where('product').equals(product)
      .where('version').equals(ver)
      .select('all date').exec (err, docs) =>
        return cb err if err
        result = {}
        startDate = stringToDate start
        for doc in docs
          result[doc.date] = doc.all
        while (date = dateToString(startDate)) <= end
          result[date] ?= occurred: 0, devices: 0
          startDate = new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate() + 1)
        cb null, result

    # 单个版本按照tag的分布
    DropboxStatSchema.statics.tagDistributionOfVersion = (product, ver, cb) ->
      @findOne().
      where("product").equals(product)
      .where("version").equals(ver)
      .where("date").equals(null)
      .select("tag").exec (err, doc) =>
        return cb err if err
        result = {}
        for tag, value of (doc?.tag or {})
          tag = @toName tag
          result[tag] = value.occurred
        cb(null, result)

    # 单个版本按照app的分布
    DropboxStatSchema.statics.appDistributionOfVersion = (product, ver, cb) ->
      @findOne().
      where("product").equals(product)
      .where("version").equals(ver)
      .where("date").equals(null)
      .select("app").exec (err, doc) =>
        return cb err if err
        result = {}
        for app, value of (doc?.app or {})
          app = @toName app
          result[app] = value.occurred
        cb(null, result)

    # 单个版本的错误率
    DropboxStatSchema.statics.errorRateOfVersion = (product, ver, cb) ->
      @findOne().
      where("product").equals(product)
      .where("version").equals(ver)
      .where("date").equals(null)
      .select("all").exec (err, doc) =>
        return cb err if err
        result = {}
        result.devices = doc?.all?.devices or 0
        result.occurred = doc?.all?.occurred or 0
        cb(null, result)

    # app列表
    DropboxStatSchema.statics.apps = (product, ver, cb) ->
      query = @find()
        .where('product').equals(product)
        .where('date').equals(null)
        .select('app')
      query = query.where('version').equals(ver) if ver
      query.exec (err, docs) =>
        return cb err if err
        cb null, _.sortBy _.unique(_.flatten(doc.apps for doc in docs))

    DropboxStatSchema.statics.tags = (product, ver, cb) ->
      query = @find()
        .where('product').equals(product)
        .where('date').equals(null)
        .select('tag')
      query = query.where('version').equals(ver) if ver
      query.exec (err, docs) =>
        return cb err if err
        cb null, _.sortBy _.unique(_.flatten(doc.tags for doc in docs))

    Dropbox: mongoose.model("#{dbprefix}.Dropbox", DropboxSchema)
    DropboxLimit: mongoose.model("#{dbprefix}.DropboxLimit", DropboxLimitSchema)
    DeviceStat: mongoose.model("#{dbprefix}.DeviceStat", DeviceStatSchema)
    DropboxStat: mongoose.model("#{dbprefix}.DropboxStat", DropboxStatSchema)
    LocationStat: mongoose.model("#{dbprefix}.LocationStat", LocationStatSchema)

  cache.put "#{dbprefix}.dropbox", cached

  cached
