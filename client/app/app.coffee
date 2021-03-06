"use strict"

angular.module "dbboardApp", [
  "ngCookies"
  "ngResource"
  "ngSanitize"
  "ngAnimate"
  "btford.socket-io"
  "ui.router"
  "ui.bootstrap"
  "adf.structures.base"
  "adf"
  "LocalStorageModule"
  "widgets.dropbox"
  "btford.markdown"
  "ui.date"
  "ui.select2"
  "ngProgress"
  "http-auth-interceptor"
  "highcharts-ng"
]
.config ($stateProvider, $urlRouterProvider, $locationProvider) ->
  $urlRouterProvider.otherwise '/'

  $locationProvider.html5Mode true
# .config (markdownConverterProvider) ->
#   markdownConverterProvider.config extensions: ["twitter"]
.run ($rootScope, $location, $state) ->
  $rootScope.$on 'event:auth-loginRequired', ->
    $rootScope.originUrl ?= $location.url()
    $state.go "login"
    false