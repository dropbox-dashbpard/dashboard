'use strict'

angular.module 'dbboardApp'
.config ($stateProvider) ->
  $stateProvider
  .state 'auth.board',
    url: '^/board'
    templateUrl: 'app/auth/board/dashboard.html'
    controller: 'BoardCtrl'
    resolve:
      Products: (dbProductService) ->
        dbProductService.get()
