'use strict'

angular.module 'dbboardApp'
.controller 'MainCtrl', ($scope, $http, socket) ->
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
              days: 90
          }
        ]
      }
    ]]

  $scope.collapsible = false

  socket.syncDBModel 'main', $scope.model, (event) ->

  $scope.$on '$destroy', ->
    socket.unsyncDBModel 'main'