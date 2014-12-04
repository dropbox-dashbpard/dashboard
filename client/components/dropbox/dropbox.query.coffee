"use strict"

angular.module("dropbox")
.factory "DropboxItem", ($resource) ->
  $resource "/api/0/dropbox/items/:itemId", {}, {
    query:
      method: "GET"
      isArray: true
      transformResponse: (body, header) ->
        JSON.parse(body).data
  }
.factory "TypeItems", ($resource) ->
  $resource "/api/0/dropbox/product/:product/:type", {}, {
    query:
      method: "GET"
      isArray: true
      transformResponse: (body, header) ->
        JSON.parse(body).data
  }
.factory "DropboxReport", ($resource) ->
  $resource "/api/0/dropbox/ea/product/:product", {}, {
    query:
      method: "GET"
      isArray: false
      transformResponse: (body, header) ->
        JSON.parse(body)
  }
