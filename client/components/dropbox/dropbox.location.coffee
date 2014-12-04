"use strict"

angular.module("dropbox")
.factory "ipLocationResource", ($resource) ->
  $resource "/api/0/util/location/:ip", {}, {
    get:
      method: "GET"
      transformResponse: (body, header) ->
        JSON.parse(body)
  }
