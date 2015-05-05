angular.module("dbboardApp")
.value("SessionUrl", "/auth/session")
.service("SessionService", ($q, $http, SessionUrl) ->
  get: ->
    deferred = $q.defer()
    $http.post(SessionUrl)
    .success (data) ->
      if data
        deferred.resolve(data)
      else
        deferred.reject()
    .error (err) ->
      deferred.reject(err)

    deferred.promise
)