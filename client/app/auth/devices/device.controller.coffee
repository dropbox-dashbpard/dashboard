'use strict'

angular.module 'dbboardApp'
.controller 'DeviceCtrl', ($scope, $http, ProductConfigModel) ->
  $scope.isCollapsed = true
  $scope.devices = ProductConfigModel.query()
.controller 'DeviceModelCtrl', ($scope, $http, $modal, ProductModel) ->
  $scope.models = ProductModel.query()
  
  $scope.open = (model, create=false) ->
    modalInstance = $modal.open
      templateUrl: 'ModelEdit.html'
      controller: 'DeviceModelEditCtrl'
      resolve:
        model: ->
          model
    modalInstance.result.then (model) ->
      model.$save()
      if create
        $scope.models = ProductModel.query()
    , (model) ->
      if not create
        model.$get()
  
  $scope.remove = (model) ->
    model.$remove()
    $scope.models = ProductModel.query()
  
  $scope.add = ->
    $scope.open new ProductModel(
      name: 'name'
      build:
        brand: 'build.brand'
        device: 'build.device'
        product: 'build.product'
        model: 'build.model'
    ), true
.controller 'DeviceModelEditCtrl', ($scope, $modalInstance, model) ->
  $scope.model = model
  $scope.ok = ->
    $modalInstance.close($scope.model)
  $scope.cancel = ->
    $modalInstance.dismiss($scope.model)


.controller 'DeviceConfigCtrl', ($scope, $http, $stateParams, $modal, ProductConfigModel) ->
  $scope.id = $stateParams.id
  $scope.config = ProductConfigModel.get
    id: $stateParams.id
  $scope.update = ->
    for limit in $scope.config.limits when angular.isString limit.fields
      limit.fields = limit.fields.split(',')
      for field in limit.fields when angular.equals field, ''
        limit.fields.splice limit.fields.indexOf(field), 1
    ProductConfigModel.update
      id: $stateParams.id,
      $scope.config
    modalInstance = $modal.open
      templateUrl: 'alertDialog.html'
      controller: 'DeviceConfigAlertCtrl'
      size: 'sm'
    modalInstance.result.then ->
.controller 'DeviceConfigBtsCtrl', ($scope, $http) ->
  $scope.modes = ['jira']
  $scope.tagAdd = (new_tag, new_value)->
    if new_tag and new_value
      $scope.config.bts.threshold ?= {}
      $scope.config.bts.threshold[new_tag] = new_value
      $scope.new_tag = null
      $scope.new_value = null
  $scope.tagRemove = (tag) ->
    delete $scope.config.bts.threshold[tag]
  $scope.compAdd = (new_comp, new_process)->
    if new_comp and new_process
      $scope.config.bts.components ?= {}
      $scope.config.bts.components[new_comp] = new_process
      $scope.new_comp = null
      $scope.new_process = null
  $scope.compRemove = (comp) ->
    delete $scope.config.bts.components[comp]
.controller 'DeviceConfigLimitsCtrl', ($scope, $http) ->
  $scope.limitRemove = (limit) ->
    $scope.config.limits.splice $scope.config.limits.indexOf(limit), 1
  $scope.limitAdd = (limit_fields, limit_value) ->
    if limit_fields and limit_value
      $scope.config.limits ?= []
      $scope.config.limits.push
        'fields': limit_fields
        'limit': limit_value
      $scope.limit_fields = null
      $scope.limit_value = null
.controller 'DeviceConfigIgnoresCtrl', ($scope, $http) ->
  $scope.ignoreRemove = (ignore) ->
    $scope.config.ignores.splice $scope.config.ignores.indexOf(ignore), 1
  $scope.ignoreAdd = (ignore_app, ignore_tag) ->
    if ignore_app and ignore_tag
      $scope.config.ignores ?= []
      $scope.config.ignores.push
        'app': ignore_app
        'tag': ignore_tag
      $scope.app = null
      $scope.tag = null
.controller('DeviceConfigTemplatesCtrl', ($scope, $http) -> )
.controller 'DeviceConfigAlertCtrl', ($scope, $modalInstance) ->
  $scope.ok = ->
    $modalInstance.close()