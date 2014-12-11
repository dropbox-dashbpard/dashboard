'use strict'

angular.module 'dbboardApp'
.controller 'AuthCtrl', ($scope, $state, Session, Products) ->
  $scope.session = Session
  $scope.products = Products

  $state.go "auth.board"
