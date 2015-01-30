'use strict'

angular.module('dbboardApp')
.factory 'queryUtilsFactory', ->
  defaultDateOfQuery: (duration=7)->
    now = new Date()
    return [
      new Date(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() - duration, now.getUTCHours())
      new Date(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() + 1, now.getUTCHours())
    ]
