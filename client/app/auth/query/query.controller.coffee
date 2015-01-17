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
.controller "QueryInAdvancedCtrl", ($rootScope, $scope, $stateParams, $location, $timeout, DropboxItem, TypeItems) ->
  now = new Date()
  $scope.from = new Date(now.getTime() - 24*3600*7000)
  $scope.to = new Date(now)

  $scope.type = if $location.path().match(/\/app$/) then "app" else "tag"
  $scope.typeDisplay = switch $scope.type
    when "app" then "应用"
    when "tag" then "类型"

  $scope.$watch "product", (newValue, oldValue) ->
    prod = _.find $scope.products, (prod) ->
      prod.name is newValue
    $scope.versions = prod?.versions
    $timeout ->
      $scope.version ?= $stateParams.version or _.flatten(_.map($scope.versions))[0]

  # seect a version
  $scope.$watch "version", (newValue, oldValue) ->
    TypeItems.query {type: $scope.type, product: $scope.product, version: newValue}, (values) ->
      $scope.typeValues = values
      $timeout ->
        $scope.value ?= $stateParams.value or values[0]

  $scope.queryInAdvance = (product, version, value, from, to) ->
    if from > to
      [from, to] = [to, from]
    params = {product: product, version: version, from: from, to: to, limit: 500}
    params[$scope.type] = value
    $rootScope.$broadcast "Change:Dropbox:Items", params if product and version and value
  
  $scope.$on "$viewContentLoaded", (event) ->
    $scope.product ?= $stateParams.product or $scope.products[0].name
    if $stateParams.product and $stateParams.version and $stateParams.value
      $scope.queryInAdvance $stateParams.product, $stateParams.version, $stateParams.value, $scope.from, $scope.to

.controller "IpLocationCtrl", ($scope, ipLocationResource) ->
  $scope.initLocation = (ip) ->
    ipLocationResource.get {ip: ip}, (location) ->
      $scope.location = location 
.controller "QueryDropboxItemCtrl", ($rootScope, $scope, $state, $stateParams) ->
  $scope.query = (id) ->
    $state.go("auth.query.dbitem", {dropboxId: id}, {reload: true}) if id
  $scope.$on "$viewContentLoaded", (event) ->
    if $stateParams.dropboxId
      $scope.dropboxId = $stateParams.dropboxId
      $rootScope.$broadcast("Change:Dropbox:Item", $scope.dropboxId)
