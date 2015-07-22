'use strict'

angular.module('dbboardApp')
.controller "DropboxItemListCtrl", ($rootScope, $scope, DropboxItem, queryUtilsFactory, ngProgress) ->
  $scope.show = false
  $scope.selectedItems = []
  $scope.itemPerPage = 5
  $scope.currentPage = 1
  $scope.maxSize = 20
  $scope.predicate = 'created_at'
  $scope.reverse = true
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
      queryUtilsFactory.durationDisplay(new Date(v))
    else
      v
  $scope.select = (item) ->
    $scope.selectedItem = item
    $rootScope.$broadcast "Change:Dropbox:Item", item._id
  $scope.order = (field) ->
    if field is $scope.predicate
      if $scope.reverse
        $scope.predicate = 'created_at'
        $scope.reverse = true
      else
        $scope.reverse = not $scope.reverse
    else
      $scope.predicate = field
      $scope.reverse = false

  $scope.$on "Change:Dropbox:Items", (event, params) ->
    if params
      ngProgress.start()
      DropboxItem.query params, (items) ->
        ngProgress.complete()
        $scope.items = items
        $scope.show = true
    else
      $scope.show = false
    $rootScope.$broadcast "Change:Dropbox:Item", null
.controller "ItemDetailCtrl", ($scope, DropboxItem, Ticket, ErrorFeature, localStorageService, ngProgress) ->
  name = "ItemDetailCtrl"
  $scope.options = localStorageService.get(name) or activeTab: {
    data: true
    trace: false
    efforfeature: false
    detail: false
  }
  $scope.active = (tab) ->
    $scope.options.activeTab[tab] = true
    localStorageService.set name, $scope.options

  $scope.trace = (traces) ->
    _.map traces, (t) ->
      [func, file] = t.replace(/[\r\n]/g, '').trim().split /\s+at\s+/
      if not file
        [func, file] = [null, func]
      [file, line] = file.split(':')
      if file?.length > 0 and file[0] is '/'
        paths = file.split '/'
        index = _.findIndex paths, (p) ->
          p in ["bionic", "cts", "development", "external", "kernel", "ndk", "pdk", "system", "abi", "bootable", "dalvik", "device", "frameworks", "libcore", "prebuilts", "tools", "art", "build", "developers", "docs", "hardware", "libnativehelper", "packages", "sdk", "vendor"]
        file = paths[index...].join('/') if index >= 0

      func: func
      file: file
      line: line

  $scope.isString = angular.isString
  $scope.isArray = angular.isArray
  $scope.show = false
  $scope.$on "Change:Dropbox:Item", (event, itemId) ->
    if itemId
      ngProgress.start()
      DropboxItem.get itemId: itemId, (item) ->
        ngProgress.complete()
        data = {}
        if item.data?.content
          data.mdContent = item.data.content
        else if item.digest?
          data.mdContent = item.digest
        else if item.data?.jsonContent?
          data.mdContent = "#{JSON.stringify(item.data.jsonContent, undefined, 2)}"
        for key, value of {
          "_id": "id"
          "device_id": "device_id"
          "app": "app"
          "version": "version"
          "attachment": "attachment"
          "errorfeature": "errorfeature"
          "tag": "tag"} when item[key]?
          data[value] = item[key]
        for prod in $scope.products when prod.name is item.product
          data.product = prod
          break
        data.occurred_at = new Date(item.occurred_at)
        data.mac_address = item.ua?.mac_address
        data.board = item.ua?.board
        data.device = item.ua?.device
        data.imei = item.ua?.imei
        data.buildtype = item.ua?.type or item.ua?.buildtype
        data.count = item.data?.count or 1
        data.ip = item.ua?.ip
        data.traces = $scope.trace(item.data?.traces or [])
        $scope.item = data
        if data.errorfeature?
          ErrorFeature.get id: data.errorfeature, (ef) ->
            $scope.errorfeature = ef
          Ticket.query errorfeature: data.errorfeature, (tickets) ->
            $scope.tickets = tickets
        $scope.show = true
    else
      $scope.show = false
.controller "IpLocationCtrl", ($scope, ipLocationResource) ->
  $scope.$watch 'item', (newValue, oldValue) ->
    if $scope.item
      ipLocationResource.get {ip: $scope.item.ip}, (location) ->
        $scope.location = location 
    else
      $scope.location = {}
