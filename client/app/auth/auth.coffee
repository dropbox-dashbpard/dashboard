"use strict"

angular.module "dbboardApp"
.config ($stateProvider) ->
  $stateProvider
  .state 'auth',
    url: '/'
    templateUrl: 'app/auth/main.html'
    controller: 'AuthCtrl'
    resolve:
      Session: (SessionService) ->
        SessionService.get()
      Products: (dbProductService) ->
        dbProductService.get()
      Releases: (dbReleaseTypesService) ->
        dbReleaseTypesService.get()
