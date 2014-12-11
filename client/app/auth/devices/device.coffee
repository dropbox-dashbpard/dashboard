'use strict'

angular.module 'dbboardApp'
.config ($stateProvider) ->
  $stateProvider
  .state 'auth.device',
    url: '^/device'
    templateUrl: 'app/auth/devices/device.container.html',
    controller: 'DeviceCtrl'
  .state 'auth.device.model',
    url: '/model'
    templateUrl: 'app/auth/devices/device.model.html',
    controller: 'DeviceModelCtrl'
  .state 'auth.device.config',
    url: '/config'
    templateUrl: 'app/auth/devices/device.config.html',
    controller: 'DeviceConfigCtrl'
