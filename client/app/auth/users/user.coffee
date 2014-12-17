'use strict'

angular.module 'dbboardApp'
.config ($stateProvider) ->
  $stateProvider
  .state 'auth.user',
    url: '^/user'
    templateUrl: 'app/auth/users/user.container.html',
    controller: 'UserCtrl'
