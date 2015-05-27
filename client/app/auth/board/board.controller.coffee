'use strict'

angular.module 'dbboardApp'
.value 'DashboardModels', [
    {
      title: ""
      structure: "6-6"
      rows: [
        columns: [
          {
            styleClass: "col-sm-6"
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
            styleClass: "col-sm-6"
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
            styleClass: "col-sm-6"
            widgets: [
              {
                type: "productDistributionWidget"
                config:
                  category: "app"
                  product: ""
                  dist: ""
                  selectDays: true
                  totalDisplay: 30
                  days: 7
              }
            ]
          }
          {
            styleClass: "col-sm-6"
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
            styleClass: "col-sm-6"
            widgets: [
              {
                type: "productDistributionWidget"
                config:
                  category: "app"
                  product: ""
                  dist: ""
                  selectDays: true
                  totalDisplay: 30
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
              styleClass: "col-sm-6"
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
              styleClass: "col-sm-6"
              widgets: [
                {
                  type: "productErrorRateOfRebootWidget"
                  config:
                    tag: "SYSTEM_LAST_KMSG"
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
            styleClass: "col-sm-12"
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
.controller 'BoardCtrl', ($scope, $http, $interval, DashboardModels, Products) ->
  p_index = 0
  d_index = 0
  m_index = 0

  Releases = []

  increaseIndex = ->
    m_index = (m_index + 1) % DashboardModels.length
    if m_index is 0
      d_index = (d_index + 1) % Releases.length
      if d_index is 0
        p_index = (p_index + 1) % Products.length

  nextModel = ->
    product = Products[p_index]
    Releases = _.filter product.versionTypes, (dist) ->
      dist.name not in ['development', 'test', 'engineering']
    dist = Releases[d_index]
    model = DashboardModels[m_index]
    version = product.versions[dist.name][0]

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

  hasVersion = _.some Products, (prod) ->
    _.some prod.versions or {}, (vers, dist) ->
      vers.length > 0

  if hasVersion  # not empty
    $scope.model = angular.copy nextModel()

    $scope.intervalUpdate = $interval ->
      model = do nextModel
      for key, value of model
        $scope.model[key] = value
    , 10 * 1000

    $scope.$on '$destroy', ->
      $interval.cancel $scope.intervalUpdate
