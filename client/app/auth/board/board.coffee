'use strict'

angular.module 'dbboardApp'
.config ($stateProvider) ->
  $stateProvider
  .state 'auth.board',
    url: '^/board'
    templateUrl: 'app/partial/dashboard.html'
    controller: 'BoardCtrl'
