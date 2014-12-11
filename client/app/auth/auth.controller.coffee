'use strict'

angular.module 'dbboardApp'
.controller 'AuthCtrl', ($scope, $state, Session, Products, Releases) ->
  $scope.session = Session
  $scope.products = Products
  $scope.releases = Releases
