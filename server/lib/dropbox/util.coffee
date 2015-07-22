"use strict"

exports = module.exports =
  dateToString: (date) ->
    return date if typeof date is 'string'
    date = new Date(date) if typeof date is 'number'
    year = date.getUTCFullYear()
    month = date.getUTCMonth() + 1
    day = date.getUTCDate()
    "#{year}#{if month > 9 then month else ('0' + month)}#{if day > 9 then day else ('0' + day)}"

  stringToDate: (date) ->
    if date not instanceof Date
      match = /(\d{4})(\d{2})(\d{2})/g.exec date
      date = new Date()
      date.setUTCFullYear match[1], Number(match[2])-1, match[3]
    date.setUTCHours 0
    date.setUTCMinutes 0
    date.setUTCSeconds 0
    date.setUTCMilliseconds 0
    date
