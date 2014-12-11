'use strict'

angular.module 'dbboardApp'
.config ($stateProvider) ->
  $stateProvider
  .state 'auth.product',
    url: '^/product/:product'
    templateUrl: 'app/auth/board/dashboard.html',
    controller: 'ProductsCtrl'
