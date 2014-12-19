'use strict'

angular.module 'dbboardApp'
.controller 'BoardCtrl', ($scope, $http, socket, Products) ->
  $scope.name = "主看板"

  $scope.model =
    title: "阿尔卑斯"
    structure: "12"
    rows: [columns: [
      {
        styleClass: "col-xs-12"
        widgets: [
          {
            type: "productTrendWidget"
            config:
              product: "alps"
              dist: "development"
              selectDays: true
              days: 30
          }
        ]
      }
    ]]

  $scope.collapsible = false

  socket.syncDBModel 'main', $scope.model, (event) ->

  $scope.$on '$destroy', ->
    socket.unsyncDBModel 'main'