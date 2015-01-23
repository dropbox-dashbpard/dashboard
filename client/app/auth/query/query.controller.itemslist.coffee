'use strict'

angular.module('dbboardApp')
.controller "DropboxItemListCtrl", ($rootScope, $scope, DropboxItem, ngProgress) ->
  $scope.show = false
  $scope.selectedItems = []
  $scope.itemPerPage = 5
  $scope.currentPage = 1
  $scope.maxSize = 20
  $scope.columns = columnDefs = [
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
  $scope.printValue = (k, v) ->
    if k is "occurred_at"
      new Date(v).toLocaleString()
    else
      v
  $scope.select = (item) ->
    $scope.selectedItem = item
    $rootScope.$broadcast "Change:Dropbox:Item", item._id

  $scope.$on "Change:Dropbox:Items", (event, params) ->
    if params
      ngProgress.start()
      DropboxItem.query params, (items) ->
        ngProgress.complete()
        $scope.items = items
        $scope.show = items?.length > 0
    else
      $scope.items = []
      $scope.show = false
    $rootScope.$broadcast "Change:Dropbox:Item", null
.controller "ItemDetailCtrl", ($scope, DropboxItem, dbTicketsService, localStorageService, ngProgress) ->
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

  $scope.show = false
  $scope.$on "Change:Dropbox:Item", (event, itemId) ->
    if itemId
      ngProgress.start()
      DropboxItem.get itemId: itemId, (item) ->
        ngProgress.complete()
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
          "errorfeature": "errorfeature"
          "tag": "tag"} when item?[key]?
          data[value] = item[key]
        for prod in $scope.products when prod.name is item?.product
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
        $scope.show = true
    else
      $scope.show = false
.controller "TicketsCtrl", ($scope, dbTicketsService) ->
  $scope.$watch 'item', (newValue, oldValue) ->
    if $scope.item
      dbTicketsService.get($scope.item.product.name, $scope.item.errorfeature).then (tickets) ->
        $scope.tickets = tickets
      , (err) ->
        $scope.tickets = []
    else
      $scope.tickets = []
.controller "IpLocationCtrl", ($scope, ipLocationResource) ->
  $scope.$watch 'item', (newValue, oldValue) ->
    if $scope.item
      ipLocationResource.get {ip: $scope.item.ip}, (location) ->
        $scope.location = location 
    else
      $scope.location = {}
