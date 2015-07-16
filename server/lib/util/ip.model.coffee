"use strict"

_ = require 'lodash'
mongoose = require 'mongoose'
request = require 'request'

require("http").globalAgent.maxSockets = 10000

Schema = mongoose.Schema

##################################################################################
# the ip to location cache
IpCacheSchema = new Schema(
  _id: Number  # ip address
  country: Object
  province: Object
  city: Object
  modified_at:
    type: Date
    expires: '30d'
,
  collection: "ipcache"
)

IpCacheSchema.methods.josn = ->
  country: @country
  province: @province
  city: @city

IpCacheSchema.virtual('ip').get ->
  id = @_id
  "#{id >> 24}.#{(id & 0xff0000) >> 16}.#{(id & 0xff00) >> 8}.#{id & 0xff}"

IpCacheSchema.statics.location = (ip, callback) ->
  m = ip.match /(\d+)\.(\d+)\.(\d+)\.(\d+)/
  if m?
    id = (Number(m[1]) << 24) + (Number(m[2]) << 16) + (Number(m[3]) << 8) + Number(m[4])
  else
    return callback "Invalid ip address #{ip}"

  @findById id, (err, doc) =>
    return callback(null, doc.josn()) if doc?
    request {
      url: "http://ip.taobao.com/service/getIpInfo.php"
      qs:
        ip: ip
     }, (err, response, body) =>
      if err or response.statusCode isnt 200
        callback "err during retrieving ip info."
      else
        try
          body = JSON.parse body
          if body.code is 0
            data = body.data
            @create({_id: id, country: data.country, province: data.region, city: data.city, modified_at: new Date}).then (doc) ->
              callback null, doc.josn()
            , (err) ->
              callback err
          else
            callback "#{JSON.stringify(body)}"
        catch e
          callback "Error during parsing json response."

exports = module.exports = mongoose.model("IpCache", IpCacheSchema)


