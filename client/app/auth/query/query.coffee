"use strict"

angular.module "dbboardApp"
.config ($stateProvider) ->
  $stateProvider
  .state "auth.query",
    url: "^/query"
    templateUrl: "app/auth/query/query.html"
    controller: "QueryCtrl"
    resolve:
      Products: (dbProductService) ->
        dbProductService.get()
  .state "auth.query.dashboard",
    url: "/dashboard"
    templateUrl: "app/auth/board/dashboard.html"
    controller: "QueryDashboardCtrl"
  .state "auth.query.device",
    url: "/device/:deviceId?from&to"
    templateUrl: "app/auth/query/query.device.html"
    controller: "QueryDataDeviceCtrl"
  .state "auth.query.mac",
    url: "/mac/:mac?from&to"
    templateUrl: "app/auth/query/query.mac.html"
    controller: "QueryDataDeviceCtrl"
  .state "auth.query.app",
    url: "/app?product&version&value"
    templateUrl: "app/auth/query/query.type.html"
    controller: "QueryInAdvancedCtrl"
  .state "auth.query.tag",
    url: "/tag?product&version&value"
    templateUrl: "app/auth/query/query.type.html"
    controller: "QueryInAdvancedCtrl"
  .state "auth.query.dbitem",
    url: "/dbitem/:dropboxId"
    templateUrl: "app/auth/query/query.dropboxid.html"
    controller: "QueryDropboxItemCtrl"
  .state "auth.query.errorfeature",
    url: "/report/errorfeature?product&version&errorfeature"
    templateUrl: "app/auth/query/query.errorfeature.html"
    controller: "QueryDropboxProductErrorFeaturesCtrl"
