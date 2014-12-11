"use strict"

angular.module "dbboardApp"
.config ($stateProvider, $urlRouterProvider, $locationProvider) ->
  $stateProvider
  .state 'login',
    url: '/login'
    templateUrl: 'app/login/login.html'
    controller: 'LoginCtrl'
