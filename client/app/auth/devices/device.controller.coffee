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


.controller 'DeviceConfigCtrl', ($scope, $http, $stateParams, ProductConfigModel) ->
  $scope.id = $stateParams.id
.controller 'DeviceConfigBtsCtrl', ($scope, $http, $stateParams, $modal, ProductConfigModel) ->
  $scope.config = ProductConfigModel.get({id: $stateParams.id})
  $scope.update = ->
    ProductConfigModel.update({id: $stateParams.id}, $scope.config)
    modalInstance = $modal.open
      templateUrl: 'alertDialog.html'
      controller: 'DeviceConfigAlertCtrl'
      size: 'sm'
    modalInstance.result.then ->
      console.log "Job done."   
.controller 'DeviceConfigLimitsCtrl', ($scope, $http, $stateParams, $modal, ProductConfigModel) ->
  $scope.config = ProductConfigModel.get({id: $stateParams.id})
  $scope.update = ->
    ProductConfigModel.update({id: $stateParams.id}, $scope.config)
    modalInstance = $modal.open
      templateUrl: 'alertDialog.html'
      controller: 'DeviceConfigAlertCtrl'
      size: 'sm'
    modalInstance.result.then ->
      console.log "Job done."        
.controller 'DeviceConfigIgnoresCtrl', ($scope, $http, $stateParams, $modal, ProductConfigModel) ->
  $scope.config = ProductConfigModel.get({id: $stateParams.id})
  $scope.update = ->
    ProductConfigModel.update({id: $stateParams.id}, $scope.config)
    modalInstance = $modal.open
      templateUrl: 'alertDialog.html'
      controller: 'DeviceConfigAlertCtrl'
      size: 'sm'
    modalInstance.result.then ->
      console.log "Job done."    
.controller 'DeviceConfigTemplatesCtrl', ($scope, $http, $stateParams, $modal, ProductConfigModel) ->
  $scope.config = ProductConfigModel.get({id: $stateParams.id})
  $scope.update = ->
    ProductConfigModel.update({id: $stateParams.id}, $scope.config)
    modalInstance = $modal.open
      templateUrl: 'alertDialog.html'
      controller: 'DeviceConfigAlertCtrl'
      size: 'sm'
    modalInstance.result.then ->
      console.log "Job done."
.controller 'DeviceConfigAlertCtrl', ($scope, $modalInstance) ->
  $scope.ok = ->
    $modalInstance.close()