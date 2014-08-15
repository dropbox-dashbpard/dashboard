'use strict'

angular.module 'dbboardApp'
.config ($stateProvider) ->
  $stateProvider
  .state 'trend',
    url: '/trend'
    templateUrl: 'app/trend/trend.html',
    controller: 'TrendCtrl'
