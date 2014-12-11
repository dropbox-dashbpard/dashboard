'use strict'

angular.module 'dbboardApp'
.config ($stateProvider) ->
  $stateProvider
  .state 'auth.product',
    url: '^/product/:product'
    templateUrl: 'app/partial/dashboard.html',
    controller: 'ProductsCtrl'
    resolve:
      products: (dbProductService) ->
        dbProductService.get()
      releases: (dbReleaseTypesService) ->
        dbReleaseTypesService.get()
