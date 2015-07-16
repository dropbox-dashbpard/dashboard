'use strict'

angular.module 'dbboardApp'
.controller 'AuthCtrl', ($scope, $state, $location, LoginService, Session, Products, $timeout) ->
  $scope.session = Session
  $scope.products = Products

  $scope.isCollapsed = true
 
  $scope.isActive = (route) ->
    $location.path().indexOf(route) is 0

  $scope.hasSubmenu = (item) ->
    item.subitems

  $scope.logout = ->
    LoginService.logout().then ->
      $state.go "login"

  if $state.is('auth')
    $state.go 'auth.locationdist'
