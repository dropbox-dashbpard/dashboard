'use strict'

angular.module('dbboardApp')
.controller "QueryInAdvancedCtrl", ($rootScope, $scope, $stateParams, $location, $timeout, DropboxItem, TypeItems, queryUtilsFactory) ->
  [$scope.from, $scope.to] = queryUtilsFactory.defaultDateOfQuery()

  $scope.type = if $location.path().match(/\/app$/) then "app" else "tag"
  $scope.typeDisplay = switch $scope.type
    when "app" then "应用"
    when "tag" then "类型"
  $scope.product ?= $stateParams.product or $scope.products[0].name
  $scope.typeValues = []
  $scope.version ?= $stateParams.version
  $scope.value ?= $stateParams.value

  # select a product then update versions
  $scope.changeProduct = (p) ->
    prod = _.find $scope.products, (prod) ->
      prod.name is p
    $scope.releases = prod.versionTypes
    $scope.versions = prod?.versions
    if $stateParams.version
      $scope.version ?= $stateParams.version

  # select a version then update values
  $scope.changeVersion = (ver) ->
    TypeItems.query {type: $scope.type, product: $scope.product, version: ver}, (values) ->
      $scope.typeValues = values
      $scope.showSelect = values?.length <= 1000
      if $stateParams.value in $scope.typeValues
        $scope.value ?= $stateParams.value

  $scope.changeValue = (v)->
    if $scope.value isnt v
      if v in $scope.typeValues
        $scope.value = v
    else if v in $scope.typeValues or []
      $scope.update()

  # select a product, then update product versions
  $scope.$watch "product", $scope.changeProduct
  # select a version, then update typeValues of the version
  $scope.$watch "version", $scope.changeVersion
  $scope.$watch "value", $scope.changeValue

  $scope.$watch "from", (newValue, oldValue) ->
    $scope.update()
  $scope.$watch "to", (newValue, oldValue) ->
    $scope.update()



  $scope.update = (product=$scope.product, version=$scope.version, value=$scope.value, from=$scope.from, to=$scope.to) ->
    if from > to
      [from, to] = [to, from]
    params = {product: product, version: version, from: from, to: to, limit: 1000}
    params[$scope.type] = value
    $rootScope.$broadcast "Change:Dropbox:Items", params if product and version and value and from and to
