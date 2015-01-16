'use strict'

angular.module('dbboardApp')
.controller "QueryDropboxProductErrorFeaturesCtrl", ($rootScope, $state, $scope, $stateParams, $location, $timeout) ->
  $scope.$watch "product", (newValue, oldValue) ->
    prod = _.find $scope.products, (prod) ->
      prod.name is newValue
    $scope.versions = prod?.versions
    $timeout ->
      $scope.version ?= $stateParams.version or _.flatten(_.map($scope.versions))[0]

  $scope.queryInAdvance = (product, version) ->
    $state.go("auth.query.errorfeature", {product: product, version: version}, {reload: true}) if product and version

  $scope.$on "$viewContentLoaded", (event) ->
    $scope.product ?= $stateParams.product or $scope.products[0].name
    if $stateParams.product and $stateParams.version
      $rootScope.$broadcast "Change:Dropbox:ProductVersion",
        product: $stateParams.product
        version: $stateParams.version
.controller "DropboxProductErrorFeaturesCtrl", ($rootScope, $scope, $anchorScroll, dbProductErrorFeatureService) ->
  $scope.itemPerPage = 5
  $scope.currentPage = 1
  $scope.$on "Change:Dropbox:ProductVersion", (event, params) ->
    $scope.product = params.product
    $scope.version = params.version
    dbProductErrorFeatureService.get(params.product, params.version, 1, 0).then (ef) ->
      $scope.errorfeatures = ef
      $scope.currentPage = ef.page
  $scope.isString = (value) ->
    typeof(value) is "string"
  $scope.isArray = (value) ->
    value instanceof Array

  $scope.selectErrorFeature = (product, version, ef) ->
    if $scope.selected is ef
      $scope.selected = null
      $rootScope.$broadcast "Change:Dropbox:Items", null
    else
      params = {product: product, version: version, errorfeature: ef}
      $rootScope.$broadcast "Change:Dropbox:Items", params
      $scope.selected = ef
    $location.hash('errorfeatureItems')
    $anchorScroll()
