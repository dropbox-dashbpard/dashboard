'use strict'

angular.module("dbboardApp")
.controller "ProductsCtrl", ($scope, localStorageService, $stateParams, Products, rebootTags) ->
  $scope.product = product = _.find Products, (prod) ->
    prod.name is $stateParams.product
  $scope.dist = dist = $stateParams.dist
  version = product?.versions?[dist]?[0]

  $scope.model =
    title: product.display
    structure: "6-6/4-4-4"
    rows: [
      {
        styleClass: "col-sm-12"
        columns: [
          {
            styleClass: "col-sm-6"
            widgets: [
              {
                type: "productTrendWidget"
                config:
                  product: product.name
                  dist: dist
                  selectDays: true
                  days: 30
              }
            ]
          }
          {
            styleClass: "col-sm-6"
            widgets: [
              {
                type: "productErrorRateWidget"
                config:
                  product: product.name
                  dist: dist
                  total: 12
                  drilldown: true
                  totalDrilldown: 12
              }
            ]
          }
        ]
      }
      {
        styleClass: "col-sm-12"
        columns: [
          {
            styleClass: "col-sm-6"
            widgets: [
              {
                type: "productDistributionWidget"
                config:
                  product: product.name
                  dist: dist
                  category: "app"
                  selectDays: true
                  totalDisplay: 12
                  days: 30
              }
            ]
          }
          {
            styleClass: "col-sm-6"
            widgets: [
              {
                type: "productDistributionWidget"
                config:
                  product: product.name
                  dist: dist
                  category: "tag"
                  selectDays: true
                  totalDisplay: 12
                  days: 30
              }
            ]
          }
        ]
      }
      {
        styleClass: "col-sm-12"
        columns: [
          {
            styleClass: "col-sm-6"
            widgets: [
              {
                type: "productErrorRateOfRebootWidget"
                config:
                  tag: "#{rebootTags[0]}"
                  product: product.name
                  dist: dist
                  total: 8
              }
            ]
          }
          {
            styleClass: "col-sm-6"
            widgets: [
              {
                type: "productErrorRateOfRebootWidget"
                config:
                  tag: "#{rebootTags[1]}"
                  product: product.name
                  dist: dist
                  total: 8
              }
            ]
          }
        ]
      }
      {
        styleClass: "col-sm-12"
        columns: [
          {
            styleClass: "col-sm-12"
            widgets: [
              {
                type: "productVersionWidget"
                config:
                  product: product.name
                  dist: dist
                  selectDays: true
                  days: 30
                  version: version
              }
            ]
          }
        ]
      }
    ]
