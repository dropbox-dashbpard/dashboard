'use strict'

angular.module 'dbboardApp'
.controller 'AuthCtrl', ($scope, $state, $location, LoginService, Session, Products) ->
  $scope.session = Session
  $scope.products = Products

  $scope.isCollapsed = false

  $scope.isActive = (route) ->
    $location.path().indexOf(route) is 0

  $scope.hasSubmenu = (item) ->
    item.subitems

  $scope.logout = ->
    LoginService.logout().then ->
      $state.go "login"
