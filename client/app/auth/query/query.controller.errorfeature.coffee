'use strict'

angular.module('dbboardApp')
.controller "QueryDropboxProductErrorFeaturesCtrl", ($rootScope, $state, $scope, $stateParams, $location, $timeout) ->
  $scope.update = ->
    if $scope.product and $scope.version
      $rootScope.$broadcast "Change:Dropbox:ProductVersion",
        product: $scope.product
        version: $scope.version
        errorfeature: $scope.errorfeature
  $scope.$watch "version", (newValue, oldValue) ->
    $scope.update()
  $scope.$watch "product", (newValue, oldValue) ->
    prod = _.find $scope.products, (prod) ->
      prod.name is newValue
    $scope.releases = prod?.versionTypes
    $scope.versions = prod?.versions
    $timeout ->
      $scope.version = $stateParams.version or _.flatten(_.map($scope.versions))[0]
  $scope.product ?= $stateParams.product or $scope.products[0].name
  $scope.errorfeature = $stateParams.errorfeature
.controller "DropboxProductErrorFeaturesCtrl", ($rootScope, $scope, $location, $anchorScroll, ngProgress, dbProductErrorFeatureService) ->
  $scope.itemPerPage = 5
  $scope.currentPage = 1
  $scope.maxSize = 20
  $scope.$on "Change:Dropbox:ProductVersion", (event, params) ->
    $scope.product = params.product
    $scope.version = params.version
    $scope.selected = null
    ngProgress.start()
    dbProductErrorFeatureService.get(params.product, params.version, 1, 0).then (ef) ->
      ngProgress.complete()
      $scope.errorfeatures = ef
      $scope.search = params.errorfeature if params.errorfeature
      $rootScope.$broadcast "Change:Dropbox:Items", null
    , (err) ->
      ngProgress.complete()
      $scope.errorfeatures = []
      $scope.search = params.errorfeature if params.errorfeature
      $rootScope.$broadcast "Change:Dropbox:Items", null
  $scope.isString = (value) ->
    typeof(value) is "string"
  $scope.isArray = (value) ->
    value instanceof Array
  $scope.selectErrorFeature = (product, version, ef) ->
    if $scope.selected is ef
      $scope.selected = null
      $rootScope.$broadcast "Change:Dropbox:Items", null
    else
      $scope.selected = ef
      $rootScope.$broadcast "Change:Dropbox:Items", {product: product, version: version, errorfeature: ef}
    $location.hash('errorfeatureItems')
    $anchorScroll()
