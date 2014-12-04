'use strict'

angular.module("dbboardApp")
.controller "ProductsCtrl", ($scope, localStorageService, $stateParams, products, rebootTags) ->
  name = "Products#{$stateParams.product.name}"
  for prod in products when prod.name is $stateParams.product
    product = prod
  model = localStorageService.get(name)

  unless model
    model =
      title: "#{product.display}"
      structure: "6-6/4-4-4"
      rows: [
        {
          styleClass: "col-xs-12"
          columns: [
            {
              styleClass: "col-xs-6"
              widgets: [
                {
                  type: "productTrendWidget"
                  config:
                    product: "#{product.name}"
                    dist: "production"
                    selectDays: true
                    days: 30
                }
              ]
            }
            {
              styleClass: "col-xs-6"
              widgets: [
                {
                  type: "productErrorRateWidget"
                  config:
                    product: "#{product.name}"
                    dist: "production"
                    total: 30
                    drilldown: true
                    totalDrilldown: 12
                }
              ]
            }
          ]
        }
        {
          styleClass: "col-xs-12"
          columns: [
            {
              styleClass: "col-xs-6"
              widgets: [
                {
                  type: "productDistributionWidget"
                  config:
                    product: "#{product.name}"
                    dist: "production"
                    category: "app"
                    selectDays: true
                    totalDisplay: 12
                    days: 30
                }
              ]
            }
            {
              styleClass: "col-xs-6"
              widgets: [
                {
                  type: "productDistributionWidget"
                  config:
                    product: "#{product.name}"
                    dist: "production"
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
          styleClass: "col-xs-12"
          columns: [
            {
              styleClass: "col-xs-6"
              widgets: [
                {
                  type: "productErrorRateOfRebootWidget"
                  config:
                    tag: "#{rebootTags[0]}"
                    product: "#{product.name}"
                    dist: "production"
                    total: 8
                }
              ]
            }
            {
              styleClass: "col-xs-6"
              widgets: [
                {
                  type: "productErrorRateOfRebootWidget"
                  config:
                    tag: "#{rebootTags[1]}"
                    product: "#{product.name}"
                    dist: "production"
                    total: 8
                }
              ]
            }
          ]
        }
      ]

  model.title = product.display
  for row in model.rows
    for column in row.columns
      for wgt in column.widgets
        wgt.config.product = product.name

  $scope.name = name
  $scope.model = model
  $scope.collapsible = false
  $scope.$on "adfDashboardChanged", (event, name, model) ->
    localStorageService.set name, model
