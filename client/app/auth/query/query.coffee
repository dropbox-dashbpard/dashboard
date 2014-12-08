"use strict"

angular.module "dbboardApp"
.config ($stateProvider) ->
  $stateProvider
  .state "auth.query",
    url: "^/query"
    templateUrl: "app/partial/query.html"
    controller: "QueryCtrl"
    resolve:
      products: (dbProductService) ->
        dbProductService.get()
      releases: (dbReleaseTypesService) ->
        dbReleaseTypesService.get()
  .state "auth.query.dashboard",
    url: "/dashboard"
    templateUrl: "app/partial/dashboard.html"
    controller: "QueryDashboardCtrl"
  .state "auth.query.device",
    url: "/device/:deviceId?from&to"
    templateUrl: "app/partial/query.device.html"
    controller: "QueryDataDeviceCtrl"
  .state "auth.query.mac",
    url: "/mac/:mac?from&to"
    templateUrl: "app/partial/query.mac.html"
    controller: "QueryDataDeviceCtrl"
  .state "auth.query.app",
    url: "/app?product&version&value"
    templateUrl: "app/partial/query.type.html"
    controller: "QueryInAdvancedCtrl"
  .state "auth.query.tag",
    url: "/tag?product&version&value"
    templateUrl: "app/partial/query.type.html"
    controller: "QueryInAdvancedCtrl"
  .state "auth.query.dbitem",
    url: "/dbitem/:dropboxId"
    templateUrl: "app/partial/query.dropboxid.html"
    controller: "QueryDropboxItemCtrl"
  .state "auth.query.report_tag",
    url: "/report/tag?product&version&value"
    templateUrl: "app/partial/query.report.html"
    controller: "QueryReportCtrl"
