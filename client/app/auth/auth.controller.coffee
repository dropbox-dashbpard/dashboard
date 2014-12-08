'use strict'

angular.module 'dbboardApp'
.controller 'AuthCtrl', ($scope, Session, Products) ->
  $scope.session = Session
  $scope.products = Products
