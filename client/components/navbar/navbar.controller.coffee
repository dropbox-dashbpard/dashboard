'use strict'

angular.module 'dbboardApp'
.controller 'NavbarCtrl', ($scope, $location) ->
  $scope.menu = [
    title: 'Home'
    link: '/'
  ,
    title: 'Trend'
    link: '/trend'
  ]
  $scope.isCollapsed = true

  $scope.isActive = (route) ->
    route is $location.path()