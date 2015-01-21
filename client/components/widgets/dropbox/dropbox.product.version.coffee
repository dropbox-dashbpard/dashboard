"use strict"

angular.module("widgets.dropbox")
.config((dashboardProvider) ->
  products = (dbProductService, config) ->
    dbProductService.get()
  trend = (dbProdTrendOfVersionService, config) ->
    end = new Date()
    end = new Date(Date.UTC(end.getFullYear(), end.getMonth(), end.getDate()))
    start = new Date(Date.UTC(end.getFullYear(), end.getMonth(), end.getDate() - (config.days ? 30)))
    dbProdTrendOfVersionService.get(config.product, config.version, start, end) if config.product and config.version
  distributionTags = (dbProdDistributionOfVersionService, config) ->
    dbProdDistributionOfVersionService.get(config.product, config.version, "tag") if config.product and config.version
  distributionApps = (dbProdDistributionOfVersionService, config) ->
    dbProdDistributionOfVersionService.get(config.product, config.version, "app") if config.product and config.version
  errorRate = (dbProdErrorRateOfVersionService, config) ->
    dbProdErrorRateOfVersionService.get(config.product, config.version) if config.product and config.version

  widget =
    reload: true

    edit:
      templateUrl: "components/widgets/dropbox/product.version.edit.html"
      controller: "productVersionEditCtrl"
      resolve:
        products: products

  dashboardProvider.widget("productVersionWidget", angular.extend(
    title: "单版本状态图"
    description: "需要选择产品，软件发布类型，软件版本"
    controller: "productVersionCtrl"
    templateUrl: "components/widgets/dropbox/versioncharts.html"
    resolve:
      products: products
      trend: trend
      distributionTags: distributionTags
      distributionApps: distributionApps
      errorRate: errorRate
    config:
      # product: ...
      # dist: ...
      selectDays: true
      days: 30
      totalDisplay: 12
  , widget)).widget("productVersionRateDetailWidget", angular.extend(
    title: "单版本错误分类数据表"
    description: "需要选择产品，软件发布类型，软件版本"
    controller: "productVersionRateDetailCtrl"
    templateUrl: "components/widgets/dropbox/versionrate.html"
    resolve:
      products: products
      distributionTags: distributionTags
      distributionApps: distributionApps
    config: {}
      # product: ...
      # dist: ...
  , widget))
).controller("productVersionEditCtrl", ($scope, config, products) ->
  $scope.products = products
  $scope.days = [10, 20, 30, 60, 90, 120, 150, 300]

  updateVersions = ->
    if config.product and config.dist
      prod = _.find products, (prod) ->
        prod.name is config.product
      $scope.versions = prod?.versions?[config.dist] or []
    else
      $scope.versions = []
    config.version = ""

  do updateVersions
  $scope.$watch "config.product", (newValue, oldValue) ->
    prod = _.find products, (prod) ->
      prod.name is config.product
    $scope.dists = prod.versionTypes
    do updateVersions
  $scope.$watch "config.dist", (newValue, oldValue) ->
    do updateVersions
).controller("productVersionCtrl", ($scope, config, rebootTags, products, trend, distributionTags, distributionApps, errorRate, chartsProvider) ->
  if trend and distributionTags and distributionApps and errorRate
    prod = _.find(products, (prod)->
      prod.name is config.product
    )
    prodDisplay = prod.display
    distDisplay = _.find(prod.versionTypes, (dist)->
      dist.name is config.dist
    ).display

    $scope.chartConfigs =[
      chartsProvider.chartDistribution({
          title: "#{prodDisplay} - 缺陷分布图"
          subtitle: "<strong>应用</strong> - #{distDisplay}: #{config.version}"
          totalDisplay: config.totalDisplay or 10
        }, distributionApps)
      chartsProvider.chartDistribution({
          title: "#{prodDisplay} - 缺陷分布图"
          subtitle: "<strong>类型</strong> - #{distDisplay}: #{config.version}"
          totalDisplay: config.totalDisplay or 10
        }, distributionTags)
      chartsProvider.chartTrend({
          title: "#{prodDisplay} - #{config.days}天缺陷趋势图"
          subtitle: "#{distDisplay}: #{config.version}"
        }, trend)
    ]

    summary =
      title: "#{prodDisplay} - #{distDisplay}: #{config.version}"
      devices: errorRate.devices
      occurred: errorRate.occurred
      rate: if errorRate.devices then errorRate.occurred/errorRate.devices else 0
      reboot: []
    summary.reboot = for k, v of distributionTags when k in rebootTags
      roocause: k
      value: v
      rate: if errorRate.devices then v/errorRate.devices else 0
    summary.rebootRate = _.reduce summary.reboot, (m, d) ->
        m + d.rate
      , 0
    $scope.summary = summary
).controller("productVersionRateDetailCtrl", ($scope, config, products, distributionTags, distributionApps) ->
  if distributionTags and distributionApps
    prod = _.find(products, (prod)->
      prod.name is config.product
    )
    prodDisplay = prod.display
    distDisplay = _.find(prod.versionTypes, (dist)->
      dist.name is config.dist
    ).display

    $scope.dataTagRates = for tag, value of distributionTags
      name: tag
      value: value
    $scope.gridTagRates =
      data: "dataTagRates"
      columnDefs: [
          field: 'name'
          displayName: '类型'
        ,
          field: 'value'
          displayName: '错误数'
      ]
      showFilter: true
      enableColumnResize: true
      multiSelect: false

    $scope.dataAppRates = for app, value of distributionApps
      name: app
      value: value
    $scope.gridAppRates =
      data: "dataAppRates"
      columnDefs: [
          field: 'name'
          displayName: '应用程序'
        ,
          field: 'value'
          displayName: '错误数'
      ]
      showFilter: true
      enableColumnResize: true
      multiSelect: false
)
