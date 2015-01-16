"use strict"

angular.module("dropbox")
.service("dbProductErrorFeatureService", ($q, $http, $cacheFactory) ->
  get: (product, version, page=1, pageSize=5) ->
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
)