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
.controller "DropboxProductErrorFeaturesCtrl", ($rootScope, $scope, $location, ngProgress, ErrorFeature) ->
  $scope.show = false
  $scope.itemPerPage = 5
  $scope.currentPage = 1
  $scope.maxSize = 20

  $scope.$on "$destroy", ->
    $scope.destroy = true

  $scope.$on "Change:Dropbox:ProductVersion", (event, params) ->
    $scope.product = params.product
    $scope.version = params.version
    $scope.selected = null
    $scope.errorfeatures = []
    $rootScope.$broadcast "Change:Dropbox:Items", null
    ngProgress.start()
    pageSize = 50

    updateResult = (query) ->
      query.$promise.then (ef) ->
        $scope.errorfeatures = $scope.errorfeatures.concat ef.data
        if ef.page < ef.pages and not $scope.destroy
          updateResult ErrorFeature.query(
            product: params.product
            version: params.version
            page: ef.page + 1
            pageSize: pageSize
          )
        else
          ngProgress.complete()
          $scope.show = $scope.errorfeatures.length > 0
          $scope.search = params.errorfeature if params.errorfeature
      , (err) ->
        ngProgress.complete()
        $scope.show = false
        $scope.search = params.errorfeature if params.errorfeature

    updateResult ErrorFeature.query(
      product: params.product
      version: params.version
      page: 1
      pageSize: pageSize
    )
  $scope.isString = angular.isString
  $scope.isArray = angular.isArray
  $scope.selectErrorFeature = (product, version, ef) ->
    if $scope.selected is ef
      $scope.selected = null
      $rootScope.$broadcast "Change:Dropbox:Items", null
    else
      $scope.selected = ef
      $rootScope.$broadcast "Change:Dropbox:Items", {product: product, version: version, errorfeature: ef}
