'use strict'

angular.module 'dbboardApp'
.value 'DashboardModels', [
    {
      title: ""
      structure: "6-6"
      rows: [
        columns: [
          {
            styleClass: "col-xs-6"
            widgets: [
              {
                type: "productTrendWidget"
                config:
                  product: ""
                  dist: ""
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
                  product: ""
                  dist: ""
                  total: 15
              }
            ]
          }
        ]
      ]
    }
    {
      title: ""
      structure: "6-6/6-6"
      rows: [
        columns: [
          {
            styleClass: "col-xs-6"
            widgets: [
              {
                type: "productDistributionWidget"
                config:
                  category: "app"
                  product: ""
                  dist: ""
                  selectDays: true
                  totalDisplay: 12
                  days: 7
              }
            ]
          }
          {
            styleClass: "col-xs-6"
            widgets: [
              {
                type: "productDistributionWidget"
                config:
                  category: "tag"
                  product: ""
                  dist: ""
                  selectDays: true
                  days: 7
                  totalDisplay: 12
              }
            ]
          }
        ]
      ,
        columns: [
          {
            styleClass: "col-xs-6"
            widgets: [
              {
                type: "productDistributionWidget"
                config:
                  category: "app"
                  product: ""
                  dist: ""
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
                  category: "tag"
                  product: ""
                  dist: ""
                  selectDays: true
                  days: 30
                  totalDisplay: 12
              }
            ]
          }
        ]
      ]
    }
    {
      title: ""
      structure: "4-4-4"
      rows: [
        {
          columns: [
            {
              styleClass: "col-xs-6"
              widgets: [
                {
                  type: "productErrorRateOfRebootWidget"
                  config:
                    tag: "SYSTEM_RESTART"
                    product: ""
                    dist: ""
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
                    tag: "APANIC_CONSOLE"
                    product: ""
                    dist: ""
                    total: 8
                }
              ]
            }
          ]
        }
      ]
    }
    {
      title: ""
      structure: "12"
      rows: [
        columns: [
          {
            styleClass: "col-xs-12"
            widgets: [
              {
                type: "productVersionWidget"
                config:
                  product: ""
                  dist: ""
                  selectDays: true
                  days: 30
                  version: ""
              }
            ]
          }
        ]
      ]
    }
  ]
.controller 'BoardCtrl', ($scope, $http, $interval, DashboardModels, Products, Releases) ->
  $scope.name = "主看板"

  p_index = 0
  d_index = 0
  m_index = 0

  increaseIndex = ->
    m_index = (m_index + 1) % DashboardModels.length
    if m_index is 0
      d_index = (d_index + 1) % Releases.length
      if d_index is 0
        p_index = (p_index + 1) % Products.length

  nextModel = ->
    product = Products[p_index]
    dist = Releases[d_index]
    model = DashboardModels[m_index]
    version = product.versions[dist.name][-1]

    do increaseIndex
    if version
      if 'title' of model
        model.title = "#{product.display} - #{dist.display}"
      for row in model.rows
        for column in row.columns
          for wgt in column.widgets
            if 'product' of wgt.config
              wgt.config.product = product.name
            if 'dist' of wgt.config
              wgt.config.dist = dist.name
            if 'version' of wgt.config
              wgt.config.version = version
      model
    else
      do nextModel

  $scope.model = angular.copy nextModel()

  $interval ->
    model = do nextModel
    for key, value of model
      $scope.model[key] = value
  , 10 * 1000

  $scope.$on '$destroy', ->
