"use strict"

angular.module "dbboardApp"
.config ($stateProvider) ->
  $stateProvider
  .state "query",
    url: "/query"
    templateUrl: "app/partial/query.html"
    controller: "QueryCtrl"
    resolve:
      products: (dbProductService) ->
        dbProductService.get()
      releases: (dbReleaseTypesService) ->
        dbReleaseTypesService.get()
  .state "query.dashboard",
    url: "/dashboard"
    templateUrl: "app/partial/dashboard.html"
    controller: "QueryDashboardCtrl"
  .state "query.device",
    url: "/device/:deviceId?from&to"
    templateUrl: "app/partial/query.device.html"
    controller: "QueryDataDeviceCtrl"
  .state "query.mac",
    url: "/mac/:mac?from&to"
    templateUrl: "app/partial/query.mac.html"
    controller: "QueryDataDeviceCtrl"
  .state "query.app",
    url: "/app?product&version&value"
    templateUrl: "app/partial/query.type.html"
    controller: "QueryInAdvancedCtrl"
  .state "query.tag",
    url: "/tag?product&version&value"
    templateUrl: "app/partial/query.type.html"
    controller: "QueryInAdvancedCtrl"
  .state "query.dbitem",
    url: "/dbitem/:dropboxId"
    templateUrl: "app/partial/query.dropboxid.html"
    controller: "QueryDropboxItemCtrl"
  .state "query.report_tag",
    url: "/report/tag?product&version&value"
    templateUrl: "app/partial/query.report.html"
    controller: "QueryReportCtrl"
