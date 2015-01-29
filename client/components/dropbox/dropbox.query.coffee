"use strict"

angular.module("dropbox")
.factory "DropboxItem", ($resource) ->
  $resource "/api/0/dropbox/items/:itemId", {}, {
    query:
      method: "GET"
      isArray: true
      transformResponse: (body, header) ->
        angular.fromJson(body)?.data
  }
.factory "TypeItems", ($resource) ->
  $resource "/api/0/dropbox/product/:product/:type", {}, {
    query:
      method: "GET"
      isArray: true
      transformResponse: (body, header) ->
        angular.fromJson(body)?.data or []
  }
.factory 'Product', ($resource, dbProductApiUrl) ->
  $resource "dbProductApiUrl/:product", {}, {
    query:
      method: 'GET'
      isArray: true
      transformResponse: (data, headers) ->
        angular.fromJson(data)?.data or []
  }
.factory 'ProductModel', ($resource) ->
  $resource "/api/0/dropbox/productmodel/:id", {id: '@_id'}
.factory 'UserModel', ($resource) ->
  $resource "/auth/users/:id", {id: '@_id'}
.factory 'ErrorFeature', ($resource) ->
  $resource "/api/0/dropbox/errorfeature/:id", {}, {
    query:
      method: 'GET'
      isArray: false
  }
.factory 'Ticket', ($resource) ->
  $resource "/api/0/dropbox/ticket/:id", {}, {
    query:
      method: 'GET'
      isArray: true
      transformResponse: (data, headers) ->
        angular.fromJson(data)?.data or []
  }
