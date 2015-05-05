"use strict"

angular.module("dropbox")
.service("dbProductErrorFeatureService", ($q, $http) ->
  get: (product, version, page=1, pageSize=5) ->  # pageSize=0 meams to get all
    deferred = $q.defer()
    url = "/api/0/dropbox/product/#{product}/errorfeatures"
    $http.get(url, params:
      version: version
      page: page
      pageSize: pageSize
    ).success((data) ->
      if data and data.data
        deferred.resolve data
      else
        deferred.reject()
    ).error ->
      deferred.reject()
    deferred.promise
).service("dbTicketsService", ($q, $http) ->
  get: (product, errorfeature) ->
    deferred = $q.defer()
    url = "/api/0/dropbox/product/#{product}/ticket"
    params = if errorfeature
      errorfeature: errorfeature
    else
      {}
    $http.get(url, params: params).success((data) ->
      if data and data.data
        deferred.resolve data.data
      else
        deferred.reject()
    ).error ->
      deferred.reject()
    deferred.promise
)