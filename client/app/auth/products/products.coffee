'use strict'

angular.module 'dbboardApp'
.config ($stateProvider) ->
  $stateProvider
  .state 'auth.product',
    url: '^/product/:product/:dist'
    templateUrl: 'app/auth/products/products.html',
    controller: 'ProductsCtrl'
    resolve:
      Products: (dbProductService) ->
        dbProductService.get()
      Releases: (dbReleaseTypesService) ->
        dbReleaseTypesService.get()
