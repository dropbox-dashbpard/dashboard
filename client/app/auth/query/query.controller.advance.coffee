'use strict'

angular.module('dbboardApp')
.controller "QueryInAdvancedCtrl", ($rootScope, $scope, $stateParams, $location, $timeout, DropboxItem, TypeItems, queryUtilsFactory) ->
  # select a product, then update product versions
  $scope.$watch "product", (newValue, oldValue) ->
    prod = _.find $scope.products, (prod) ->
      prod.name is newValue
    $scope.releases = prod.versionTypes
    $scope.versions = prod?.versions
    $timeout ->
      $scope.version = $stateParams.version or _.flatten(_.map($scope.versions))[0]
  # select a version then update values
  $scope.$watch "version", (newValue, oldValue) ->
    if newValue?
      TypeItems.query {type: $scope.type, product: $scope.product, version: newValue}, (values) ->
        $scope.typeValues = values
        if $scope.value and $scope.value is ($stateParams.value or values[0])
          $scope.update()
        else
          $scope.value = $stateParams.value or values[0]
  $scope.$watch "from", (newValue, oldValue) ->
    $scope.update()
  $scope.$watch "to", (newValue, oldValue) ->
    $scope.update()
  $scope.$watch "value", (newValue, oldValue) ->
    $scope.update()

  [$scope.from, $scope.to] = queryUtilsFactory.defaultDateOfQuery()

  $scope.type = if $location.path().match(/\/app$/) then "app" else "tag"
  $scope.typeDisplay = switch $scope.type
    when "app" then "应用"
    when "tag" then "类型"
  $scope.product ?= $stateParams.product or $scope.products[0].name

  $scope.update = (product=$scope.product, version=$scope.version, value=$scope.value, from=$scope.from, to=$scope.to) ->
    if from > to
      [from, to] = [to, from]
    params = {product: product, version: version, from: from, to: to, limit: 1000}
    params[$scope.type] = value
    $rootScope.$broadcast "Change:Dropbox:Items", params if product and version and value and from and to
