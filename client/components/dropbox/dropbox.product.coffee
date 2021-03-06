"use strict"

angular.module("dropbox")
.value("dbReleasesApiUrl", "/api/0/dropbox/releases")
.value("dbProductApiUrl", "/api/0/dropbox/product")
.value("dbProductVersionslApiUrl", "/api/0/dropbox/product")
.service("dbProductService", ($q, $http, $cacheFactory, dbProductApiUrl) ->
  get: ->
    deferred = $q.defer()
    $http.get(dbProductApiUrl).success((data) ->
      if data?.data
        for prod in data.data
          for key, vers of prod.versions or {}
            prod.versions[key] = (v for v in _.sortBy(vers) by -1)
        deferred.resolve data.data
      else
        deferred.reject()
    ).error ->
      deferred.reject()
    deferred.promise
).service("dbProductVersionsService", ($q, $http, dbProductVersionslApiUrl) ->
  get: (product, dist) ->
    deferred = $q.defer()
    url = "#{dbProductVersionslApiUrl}/#{product}"
    $http.get(url).success((data) ->
      if data and data.versions
        for key, vers of data.versions
          data.versions[key] = (v for v in _.sortBy(vers) by -1)
        deferred.resolve data.versions
      else
        deferred.reject()
    ).error ->
      deferred.reject()
    deferred.promise
).service("dbProdTrendService", ($q, $http, dbProductVersionslApiUrl) ->
  get: (product, dist, start, end) ->
    deferred = $q.defer()
    url = "#{dbProductVersionslApiUrl}/#{product}/trend"
    end ?= new Date()
    start ?= new Date(end.getFullYear(), end.getMonth(), end.getDate() - 30)
    $http.get(url,
      params:
        dist: dist
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
).service("dbProdDistributionService", ($q, $http, dbProductVersionslApiUrl) ->
  get: (product, dist, category, start, end) ->
    deferred = $q.defer()
    url = "#{dbProductVersionslApiUrl}/#{product}/distribution/#{category}"
    end ?= new Date()
    start ?= new Date(end.getFullYear(), end.getMonth(), end.getDate() - 30)
    $http.get(url,
      params:
        dist: dist
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
).service("dbProdErrorRateService", ($q, $http, dbProductVersionslApiUrl) ->
  get: (product, dist, total, drilldown=false) ->
    deferred = $q.defer()
    url = "#{dbProductVersionslApiUrl}/#{product}/errorrate"
    $http.get(url,
      params:
        dist: dist
        total: total
        drilldown: drilldown
    ).success((data) ->
      if data and data.data
        deferred.resolve data.data
      else
        deferred.reject()
    ).error ->
      deferred.reject()

    deferred.promise
).service("dbProdErrorRateOfTagService", ($q, $http, dbProductVersionslApiUrl) ->
  get: (product, dist, tag, total) ->
    deferred = $q.defer()
    url = "#{dbProductVersionslApiUrl}/#{product}/errorrate/tag/#{tag}"
    $http.get(url,
      params:
        dist: dist
        total: total
    ).success((data) ->
      if data and data.data
        deferred.resolve data.data
      else
        deferred.reject()
    ).error ->
      deferred.reject()

    deferred.promise
).service("dbProdErrorRateOfAppService", ($q, $http, dbProductVersionslApiUrl) ->
  get: (product, dist, app, total) ->
    deferred = $q.defer()
    url = "#{dbProductVersionslApiUrl}/#{product}/errorrate/app/#{app}"
    $http.get(url,
      params:
        dist: dist
        total: total
    ).success((data) ->
      if data and data.data
        deferred.resolve data.data
      else
        deferred.reject()
    ).error ->
      deferred.reject()
    deferred.promise
)
