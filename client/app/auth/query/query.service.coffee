'use strict'

angular.module('dbboardApp')
.factory 'queryUtilsFactory', ->
  defaultDateOfQuery: (duration=7)->
    now = new Date()
    return [
      new Date(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() - duration, now.getUTCHours())
      new Date(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() + 1, now.getUTCHours())
    ]
  durationDisplay: (from, to=null) ->
    to = new Date() if to is null
    duration = new Date(to - from)
    zero = new Date(0)
    if duration < zero
      "穿越了..."
    else if duration.getUTCFullYear() - zero.getUTCFullYear() > 0
      "#{duration.getUTCFullYear() - zero.getUTCFullYear()}年前"
    else if duration.getUTCMonth() - zero.getUTCMonth() > 0
      "#{duration.getUTCMonth() - zero.getUTCMonth()}月前"
    else if duration.getUTCDate() - zero.getUTCDate() > 0
      "#{duration.getUTCDate() - zero.getUTCDate()}天前"
    else if duration.getUTCHours() - zero.getUTCHours() > 0
      "#{duration.getUTCHours() - zero.getUTCHours()}小时前"
    else if duration.getUTCMinutes() - zero.getUTCMinutes() > 0
      "#{duration.getUTCMinutes() - zero.getUTCMinutes()}分钟前"
    else
      "刚才"
