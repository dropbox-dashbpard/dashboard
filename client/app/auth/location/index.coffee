'use strict'

angular.module 'dbboardApp'
.config ($stateProvider) ->
  $stateProvider
    .state 'auth.locationdist',
      url: '^/dist'
      templateUrl: 'app/auth/location/index.html'
      controller: 'LocationDistributionCtrl'
      resolve:
        LocationStat: (LocationDistribution) ->
          LocationDistribution.query(days: 15).$promise
