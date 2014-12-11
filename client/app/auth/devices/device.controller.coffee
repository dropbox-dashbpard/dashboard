'use strict'

angular.module 'dbboardApp'
.controller 'DeviceCtrl', ($scope, $http) ->
  console.log ""
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
.controller 'DeviceConfigCtrl', ($scope, $http) ->
  console.log ""
