angular.module("dbboardApp")
.value("LoginUrl", "/auth/login")
.value("LogoutUrl", "/auth/logout")
.service("LoginService", ($q, $http, LoginUrl, LogoutUrl, $rootScope) ->
  login: (email, password) ->
    deferred = $q.defer()
    $http.post(LoginUrl,
      email: email
      password: password
    ).success((data) ->
      if data
        deferred.resolve(data)
      else
        deferred.reject()
    ).error (err) ->
      deferred.reject(err)
    deferred.promise
  logout: ->
    deferred = $q.defer()
    $http.post(LogoutUrl).success( ->
      deferred.resolve()
    ).error (err) ->
      deferred.reject(err)
    deferred.promise
)
