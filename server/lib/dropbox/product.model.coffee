'use strict'

_ = require 'lodash'
ejs = require 'ejs'
mongoose= require 'mongoose'
cache = require 'memory-cache'

Schema = mongoose.Schema

exports = module.exports = (dbprefix) ->

  cached = cache.get("#{dbprefix}.product") or do ->
    # map brand/board/device/product/model in ua string to a specific product name
    ProductSchema = new Schema(
      name:
        type: String
        required: true
      build:
        brand: String
        device: String
        product: String
        model: String
    ,
      collection: "#{dbprefix}.products"
    )

    ProductSchema.index {build: 1}

    ProductConfigSchema = new Schema(
      _id: String
      display: String
      template:
        type: Object
        default:
          version: '<%= build_id %>'
          device_id: '<%= sn %>'
          version_validation: '^\\d+\\.\\d+$'
      versions:
        type: Object
        default:
          production: []  # 产品正式发布版本
          stable: []  # 稳定版本，类似于weekly stable build
          development: []  # 开发版本，可以使daily build
      versionTypes:
        type: Array
        default: [
          {
            name: 'production'
            display: '产品发布（最终用户）'
          }
          {
            name: 'stable'
            display: '稳定版本（内测用户）'
          }
          {
            name: 'development'
            display: '开发版本（工程测试）'
          }
        ]
      ignores:
        type: Array
        default: [
          {
            app: 'system'
            tag: 'SYSTEM_BOOT'
          }, {
            app: 'system'
            tag: 'SYSTEM_RECOVERY_LOG'
          }
        ]
      limits:
        type: Array
        default: [
          {
            fields: ['product', 'version', 'app', 'tag'],
            limit: 10  # 10 per day
          },
          {
            fields: ['product', 'version'],
            limit: 3000
          }
        ]
      bts:  # bug tracking system
        type:
          type: String
          default: 'jira'
        username: String
        password: String
        url: String
        project: String
        ver_control: Object
        threshold: Object
        components: Object
    ,
      collection: "#{dbprefix}.productconfigs"
    )

    ProductConfigSchema.virtual('name').get ->
      @_id
    ProductConfigSchema.virtual('name').set (value)->
      @_id = value

    ProductConfigSchema.methods.limit_kvs = (entry) ->
      _.map @limits, (limit) ->
        key = _.reduce limit.fields, (memo, field) ->
          memo[field] = entry[field]
          memo
        , {}

        key: key
        limit: limit.limit

    ProductConfigSchema.methods.shouldIgnore = (app, tag) ->
      _.find @ignores or [], (ig) ->
        if ig.app? and ig.tag?
          ig.app is app and ig.tag is tag
        else if ig.app?
          ig.app is app
        else if ig.tag?
          ig.tag is tag
        else
          false

    ProductConfigSchema.methods.addVersion = (type, ver, cb) ->
      if ver not instanceof Array
        ver = [ver]
      ver = _.filter ver, (v) =>
        @validVersion v

      moreStable = true
      for vt in @versionTypes
        if vt.name is type
          if ver.length > 0
            @set "versions.#{type}", _.sortBy(_.union(@versions[type] or [], ver))[-64..]  # up to 64 versions for each type
          moreStable = false
        else if moreStable
          ver = _.difference ver, @versions[vt.name]
        else
          if ver.length > 0
            @set "versions.#{vt.name}", _.difference(@versions[vt.name], ver)
      @save cb

    ProductConfigSchema.methods.validVersion = (ver) ->
      RegExp(@template.version_validation).exec ver

    ProductConfigSchema.methods.builds = (cb) ->
      mongoose.model("#{dbprefix}.Product").find name: @name, (err, prods) ->
        return cb err if err
        cb null, _.map prods, (prod) ->
          prod.build

    ProductConfigSchema.methods.device_id = (ua) ->
      ejs.render @template.device_id, ua

    ProductConfigSchema.methods.version = (ua) ->
      ejs.render @template.version, ua

    Product: mongoose.model("#{dbprefix}.Product", ProductSchema)
    ProductConfig: mongoose.model("#{dbprefix}.ProductConfig", ProductConfigSchema)

  cache.put "#{dbprefix}.product", cached

  cached
