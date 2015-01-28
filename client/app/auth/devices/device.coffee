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
    url: '^/device/config/:id'
    templateUrl: 'app/auth/devices/device.config.html',
    controller: 'DeviceConfigCtrl'
  .state 'auth.device.config.bts',
    url: '/bts'
    templateUrl: '/app/auth/devices/device.config.bts.html',
    controller: 'DeviceConfigBtsCtrl'
  .state 'auth.device.config.limits',
    url: '/limits'
    templateUrl: '/app/auth/devices/device.config.limits.html',
    controller: 'DeviceConfigLimitsCtrl'
  .state 'auth.device.config.ignores',
    url: '/ignores'
    templateUrl: '/app/auth/devices/device.config.ignores.html',
    controller: 'DeviceConfigIgnoresCtrl'
  .state 'auth.device.config.templates',
    url: '/templates'
    templateUrl: '/app/auth/devices/device.config.templates.html',
    controller: 'DeviceConfigTemplatesCtrl'
