'use strict'

angular.module 'dbboardApp'
.controller 'LoginCtrl', ($scope, $rootScope, $location, $state, LoginService) ->
  $scope.error = {}
  $scope.login = (form) ->
    $scope.errors = {}
    LoginService.login($scope.user.email, $scope.user.password).then (user) ->
      $location.path $rootScope.originUrl or '/'
      $rootScope.originUrl = null
    , (err) ->
      angular.forEach err.errors, (error, field) ->
        form[field].$setValidity('mongoose', false)
        $scope.errors[field] = error.type
      $scope.error.other = err.message
