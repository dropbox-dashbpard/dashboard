"use strict"

angular.module("dropbox")
.service("dbProdDistributionOfVersionService", ($q, $http, dbProductVersionslApiUrl) ->
  get: (product, version, category) ->
    deferred = $q.defer()
    url = "#{dbProductVersionslApiUrl}/#{product}/distributionofversion/#{category}"
    $http.get(url,
      params:
        version: version
    ).success((data) ->
      if data and data.data
        deferred.resolve data.data
      else
        deferred.reject()
    ).error ->
      deferred.reject()
 
    deferred.promise
).service("dbProdTrendOfVersionService", ($q, $http, dbProductVersionslApiUrl) ->
  get: (product, version, start, end) ->
    deferred = $q.defer()
    url = "#{dbProductVersionslApiUrl}/#{product}/trendofversion"
    $http.get(url,
      params:
        version: version
        start: start
        end: end
    ).success((data) ->
      if data and data.data
        deferred.resolve data.data
      else
        deferred.reject()
    ).error ->
      deferred.reject()
 
    deferred.promise
).service("dbProdErrorRateOfVersionService", ($q, $http, dbProductVersionslApiUrl) ->
  get: (product, version, start, end) ->
    deferred = $q.defer()
    url = "#{dbProductVersionslApiUrl}/#{product}/errorrateofversion"
    $http.get(url,
      params:
        version: version
    ).success((data) ->
      if data and data.data
        deferred.resolve data.data
      else
        deferred.reject()
    ).error ->
      deferred.reject()
 
    deferred.promise
)