'use strict'

angular.module 'dbboardApp'
.config ($stateProvider) ->
  $stateProvider
  .state 'main',
    url: '/'
    templateUrl: 'app/partial/dashboard.html'
    controller: 'MainCtrl'
