'use strict'

angular.module('dbboardApp')
.controller "QueryCtrl", ($scope, $state, Products, Releases) ->
  $scope.stateContains = (name) ->
    $state.includes name 
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
  $scope.from = new Date($stateParams.from or (now.getTime() - 24*3600*1000))
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
  $scope.from = new Date(now.getTime() - 24*3600*1000)
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

.controller "DropboxItemListCtrl", ($rootScope, $scope, localStorageService, DropboxItem) ->
  $scope.selectedItems = []
  columnDefs = [
    #   field: "_id"
    #   displayName: "#"
    # ,
      field: "device_id"
      displayName: "设备ID"
    ,
      field: "occurred_at"
      displayName: "发生时间"
    ,
      field: "app"
      displayName: "应用名称"
    ,
      field: "tag"
      displayName: "类别"
    ,
      field: "version"
      displayName: "软件版本"
    ]
  $scope.gridItems = {
    data: "items"
    multiSelect: false
    columnDefs: columnDefs
    selectedItems: $scope.selectedItems
    showFilter: true
    enableColumnResize: true
    # plugins: [new ngGridFlexibleHeightPlugin()]
  }

  $scope.reloading = false
  $scope.$on "Change:Dropbox:Items", (event, params) ->
    $scope.reloading = true
    DropboxItem.query params, (items) ->
      $scope.reloading = false
      $scope.items = items

  $scope.$watchCollection "selectedItems", (newNames, oldNames) ->
    if newNames.length > 0
      $rootScope.$broadcast "Change:Dropbox:Item", newNames[0]._id
.controller "ItemDetailCtrl", ($scope, DropboxItem, localStorageService) ->
  name = "ItemDetailCtrl"
  options = localStorageService.get name
  unless options
    options =
      activeTab:
        data: true
        detail: false
  $scope.options = options
  $scope.active = (tab) ->
    $scope.options.activeTab[tab] = true
    localStorageService.set name, $scope.options

  $scope.$on "Change:Dropbox:Item", (event, itemId) ->
    if itemId
      $scope.reloading = true
      DropboxItem.get itemId: itemId, (item) ->
        $scope.reloading = false
        data = {}
        if item?.data?.content
          data.mdContent = item.data.content
        else if item?.digest?
          data.mdContent = item.digest
        else if item?.data?.jsonContent?
          data.mdContent = "#{JSON.stringify(item.data.jsonContent, undefined, 2)}"
        for key, value of {
          "_id": "id"
          "device_id": "device_id"
          "app": "app"
          "version": "version"
          "attachment": "attachment"
          "tag": "tag"} when item?[key]?
          data[value] = item[key]
        for prod in $scope.products when prod.sys_name is item?.sys_name
          data.product = prod 
          break
        data.occurred_at = new Date(item.occurred_at)
        data.mac_address = item?.ua?.mac_address
        data.board = item?.ua?.board
        data.device = item?.ua?.device
        data.buildtype = item?.ua?.type
        data.count = item?.data?.count or 1
        data.ip = item?.ua?.ip
        $scope.item = data
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
.controller "QueryReportCtrl", ($rootScope, $state, $scope, $stateParams, $location, $timeout, DropboxItem, TypeItems) ->
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

  $scope.queryInAdvance = (product, version, value) ->
    $state.go("auth.query.report_tag", {product: product, version: version, value: value}, {reload: true}) if product and version and value
    params = {product: product, version: version}
    params[$scope.type] = value
    $rootScope.$broadcast "Change:Dropbox:Report", params if product and version and value

  $scope.$on "$viewContentLoaded", (event) ->
    $scope.product ?= $stateParams.product or $scope.products[0].name
    if $stateParams.product and $stateParams.version and $stateParams.value
      params = {product: $stateParams.product, version: $stateParams.version}
      params[$scope.type] = $stateParams.value
      $rootScope.$broadcast "Change:Dropbox:Report", params
.controller "DropboxReportDetailCtrl", ($rootScope, $scope, filterFilter, DropboxReport) ->
  $scope.reloading = false
  $scope.issues = []
  $scope.issueData =
    issueQuery: ""
    itemsPerPage: 5
    numPages: 10
    maxSize: 10
    currentPage: 1
    totalItems: 0
  $scope.$on "Change:Dropbox:Report", (event, params) ->
    $scope.reloading = true
    DropboxReport.query params, (report) ->
      $scope.reloading = false
      $scope.report = report

  $scope.updateFilter = ->
    $scope.issues = filterFilter($scope.report?.issues or [], $scope.issueData.issueQuery)
    pages = Math.ceil($scope.issues.length / $scope.issueData.itemsPerPage) or 1
    $scope.issueData.currentPage = pages if $scope.issueData.currentPage > pages
  $scope.$watch "report", $scope.updateFilter
  $scope.$watch "issueData.issueQuery", $scope.updateFilter

  $scope.composeMarkdown = (feature) ->
    _.reduce feature, (result, value, key) ->
      if key.toUpperCase() is "BACKTRACECODE"
        ""
      else
        "#{result}\r\n    #{key.toUpperCase()}: #{value}"
    , ""
.controller "DropboxIDListCtrl", ($scope, $rootScope) ->
  $scope.init = (ids) ->
    $scope.ids = ids
    do $scope.init_class
  $scope.show = (id, $event) ->
    $rootScope.$broadcast "Change:Dropbox:Item", id
    $event.preventDefault()
  $scope.page = 0
  $scope.per_page = 10
  $scope.init_class = ->
    $scope.preClass = do $scope.getPreClass
    $scope.nextClass = do $scope.getNextClass
  $scope.getPreClass = ->
    if $scope.page is 0 then "disabled" else null
  $scope.getNextClass = ->
    if ($scope.page + 1) * $scope.per_page >= $scope.ids.length then "disabled" else null
  $scope.pre = ($event) ->
    $scope.page -= 1 if $scope.page > 0
    do $scope.init_class
    $event.preventDefault()
  $scope.next = ($event) ->
    $scope.page += 1 if ($scope.page + 1) * $scope.per_page < $scope.ids.length
    do $scope.init_class
    $event.preventDefault()
