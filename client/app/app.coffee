"use strict"

angular.module "dbboardApp", [
  "ngCookies"
  "ngResource"
  "ngSanitize"
  "btford.socket-io"
  "ui.router"
  "ui.bootstrap"
  "structures"
  "adf"
  "LocalStorageModule"
  "widgets.dropbox"
  "ui.date"
  "btford.markdown"
  "ui.select2"
]
.config ($stateProvider, $urlRouterProvider, $locationProvider) ->
  $urlRouterProvider
  .otherwise "/"

  $locationProvider.html5Mode true
# .config (markdownConverterProvider) ->
#   markdownConverterProvider.config extensions: ["twitter"]