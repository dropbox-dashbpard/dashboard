'use strict'

angular.module('dbboardApp')
.controller "QueryInCustomCtrl", ($rootScope, $scope, $stateParams, $location, $timeout, TypeItems, queryUtilsFactory) ->
  [$scope.from, $scope.to] = queryUtilsFactory.defaultDateOfQuery()

  $scope.product ?= $stateParams.product or $scope.products[0].name
  $scope.value ?= $stateParams.value

  $scope.query = (product=$scope.product, value=$scope.value, from=$scope.from, to=$scope.to) ->
    if from > to
      [from, to] = [to, from]
    params = {product: product, version: 'all', app:value, from: from, to: to, limit: 1000}
    $rootScope.$broadcast "Change:Dropbox:Items", params if product and value and from and to
