'use strict'

angular.module('dbboardApp')
.controller "QueryCtrl", ($scope, $state, Products, Releases) ->
  $scope.products = Products
  $scope.releases = Releases
.controller "QueryDashboardCtrl", ($scope, localStorageService) ->
  name = "QueryDashboard"
  model = localStorageService.get(name)
  unless model
    # set default model for demo purposes
    model =
      title: "仪表盘"
      structure: "4-8"
      rows: [
        {
          styleClass: "col-sm-12"
          columns: [
            {
              styleClass: "col-sm-6"
              widgets: []
            }
            {
              styleClass: "col-sm-6"
              widgets: []
            }
          ]
        }
      ]
  $scope.name = name
  $scope.model = model
  $scope.$on "adfDashboardChanged", (event, name, model) ->
    localStorageService.set name, model
.controller "QueryDataDeviceCtrl", ($rootScope, $scope, $state, DropboxItem, $stateParams) ->
  now = new Date()
  $scope.from = new Date($stateParams.from or (now.getTime() - 24*3600*7000))
  $scope.to = new Date($stateParams.to or now)
  $scope.queryDevice = (deviceId, from, to) ->
    $state.go("auth.query.device", {deviceId: deviceId, from: from, to: to}, {reload: true}) if deviceId and from and to
  $scope.queryMac = (deviceId, from, to) ->
    $state.go("auth.query.mac", {mac: deviceId, from: from, to: to}, {reload: true}) if deviceId and from and to
  # When the controller is running, the child controller isn't. If we broadcase event here,
  # the child will not receive it. so we have to broadcase event to child controller after viewContentLoaded.
  $scope.$on "$viewContentLoaded", (event) ->
    [from, to] = [$scope.from, $scope.to]
    [from, to] = [to, from] if from > to
    if $scope.deviceId = $stateParams.deviceId
      $rootScope.$broadcast "Change:Dropbox:Items", {device_id: $scope.deviceId, from: $scope.from, to: $scope.to, limit: 500}
    else if $scope.deviceId = $stateParams.mac
      $rootScope.$broadcast "Change:Dropbox:Items", {mac: $scope.deviceId, from: $scope.from, to: $scope.to, limit: 500}
.controller "QueryDropboxItemCtrl", ($rootScope, $scope, $state, $stateParams) ->
  $scope.query = (id) ->
    $state.go("auth.query.dbitem", {dropboxId: id}, {reload: true}) if id
  $scope.$on "$viewContentLoaded", (event) ->
    if $stateParams.dropboxId
      $scope.dropboxId = $stateParams.dropboxId
      $rootScope.$broadcast("Change:Dropbox:Item", $scope.dropboxId)
