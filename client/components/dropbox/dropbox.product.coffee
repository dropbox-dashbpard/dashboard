"use strict"

angular.module("dropbox")
.value("dbReleasesApiUrl", "/api/0/dropbox/releases")
.value("dbProductApiUrl", "/api/0/dropbox/products")
.value("dbProductVersionslApiUrl", "/api/0/dropbox/product")
.service("dbReleaseTypesService", ($q, $http, $cacheFactory, dbReleasesApiUrl) ->
  if not (cache = $cacheFactory.get("dropbox"))
    cache = $cacheFactory("dropbox")

  get: ->
    deferred = $q.defer()
    if cache.get(dbReleasesApiUrl)
      deferred.resolve cache.get(dbReleasesApiUrl) 
    else
      $http.get(dbReleasesApiUrl).success((data) ->
        if data and data.data
          types = for k of data.data
            name: k
            display: data.data[k]
          deferred.resolve types
          cache.put(dbReleasesApiUrl, types)
        else
          deferred.reject()
      ).error ->
        deferred.reject()
    deferred.promise
).service("dbProductService", ($q, $http, $cacheFactory, dbProductApiUrl) ->
  if not (cache = $cacheFactory.get("dropbox"))
    cache = $cacheFactory("dropbox")

  get: ->
    deferred = $q.defer()
    if cache.get(dbProductApiUrl)
      deferred.resolve cache.get(dbProductApiUrl)
    else
      $http.get(dbProductApiUrl).success((data) ->
        if data and data.data
          deferred.resolve data.data
          cache.put(dbProductApiUrl, data.data)
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
          data.versions[key] = (v for v in _.sortBy(data.versions[key]) by -1)
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
