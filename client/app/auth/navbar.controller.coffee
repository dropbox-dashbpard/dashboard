"use strict"

angular.module("dbboardApp")
.controller "NavbarCtrl", ($scope, $state, $location, LoginService) ->
  $scope.isCollapsed = false

  $scope.isActive = (route) ->
    $location.path().indexOf(route) is 0

  $scope.hasSubmenu = (item) ->
    item.subitems

  $scope.logout = ->
    LoginService.logout().then ->
      $state.go "login"
