"use strict"

angular.module("widgets.dropbox")
.config((dashboardProvider) ->
  trend = (dbProdTrendService, config) ->
    end = new Date()
    end = new Date(Date.UTC(end.getFullYear(), end.getMonth(), end.getDate()))
    start = new Date(Date.UTC(end.getFullYear(), end.getMonth(), end.getDate() - (config.days ? 30)))
    dbProdTrendService.get(config.product, config.dist, start, end) if config.product and config.dist
  products = (dbProductService, config) ->
    dbProductService.get()
  distribution = (dbProdDistributionService, config) ->
    end = new Date()
    end = new Date(Date.UTC(end.getFullYear(), end.getMonth(), end.getDate()))
    start = new Date(Date.UTC(end.getFullYear(), end.getMonth(), end.getDate() - (config.days ? 30)))
    dbProdDistributionService.get(config.product, config.dist, config.category, start, end) if config.product and config.dist and config.category
  errorRate = (dbProdErrorRateService, config) ->
    dbProdErrorRateService.get(config.product, config.dist, config.total or 20, config.drilldown) if config.product and config.dist
  errorRateOfTag = (dbProdErrorRateOfTagService, config) ->
    dbProdErrorRateOfTagService.get(config.product, config.dist, config.tag, config.total or 20) if config.product and config.dist and config.tag
  errorRateOfApp = (dbProdErrorRateOfAppService, config) ->
    dbProdErrorRateOfAppService.get(config.product, config.dist, config.app, config.total or 20) if config.product and config.dist and config.app

  widget =
    templateUrl: "components/widgets/dropbox/singlechart.html"
    reload: true

    edit:
      templateUrl: "components/widgets/dropbox/product.dist.edit.html"
      controller: "productsDistCtrl"
      resolve:
        products: products

  dashboardProvider.widget("productTrendWidget", angular.extend(
      title: "缺陷趋势图"
      description: "特定产品以及特定软件发布类型的上报错误趋势图"
      controller: "productTrendCtrl"
      resolve:
        products: products
        trend: trend
      config:
        # product:  ...
        # dist: "production", "stable", "development"
        selectDays: true
        # days: 30
    , widget)
  ).widget("productDistributionWidget", angular.extend(
      title: "缺陷分布图"
      description: "特定产品以及特定软件发布类型的上报错误分布图"
      controller: "productDistributionCtrl"
      resolve:
        products: products
        distribution: distribution
      config:
        # category: "app" or "tag"
        # product:  ...
        # dist: "production", "stable", "development"
        selectCategory: true
        selectDays: true
        totalDisplay: 12
        # days: 30
    , widget))
  .widget("productErrorRateWidget", angular.extend(
      title: "缺陷率"
      description: "特定产品以及特定软件发布类型在不同版本的错误率"
      controller: "productErrorRateCtrl"
      resolve:
        products: products
        errorRate: errorRate
      config:
        # product:  ...
        # dist: "production", "stable", "development"
        drilldown: true
        totalDrilldown: 12
        total: 30
    , widget))
  .widget("productErrorRateOfRebootWidget", angular.extend(
      title: "重启率"
      description: "特定产品以及特定软件发布类型在不同版本的重启率"
      controller: "productErrorRateOfTagCtrl"
      resolve:
        products: products
        errorRateOfTag: errorRateOfTag
      config:
        # product:  ...
        # dist: "production", "stable", "development"
        # tag: ["SYSTEM_RESTART", "DEVICE_REBOOT", "APANIC_CONSOLE"]
        selectTag: true
        total: 20
    , widget))
  .widget("productErrorRateOfAppWidget", angular.extend(
      title: "应用缺陷率"
      description: "特定产品和软件发布类型的特定应用程序在不同版本的错误率"
      controller: "productErrorRateOfAppCtrl"
      resolve:
        products: products
        errorRateOfApp: errorRateOfApp
      config:
        # product:  ...
        # dist: "production", "stable", "development"
        category: "app"
        selectApp: true
        drilldown: true
        totalDrilldown: 12
        total: 30
    , widget))
).controller("productsDistCtrl", ($scope, config, products, rebootTags, TypeItems) ->
  $scope.products = products
  $scope.$watch "config.product", (newValue, oldValue) ->
    prod = _.find(products, (prod)->
      prod.name is config.product
    )
    $scope.dists = prod.versionTypes
  $scope.days = [10, 20, 30, 60, 90, 120, 150, 300]
  $scope.categories = ["app", "tag"]
  $scope.tags = rebootTags
  if config.selectApp
    $scope.$watch "config.product", (newValue, oldValue) ->
      if config.product
        $scope.apps = TypeItems.query {type: config.category, product: config.product}
).controller("productTrendCtrl", ($scope, config, trend, products, chartsProvider) ->
  if trend
    prod = _.find(products, (prod)->
      prod.name is config.product
    )
    prodDisplay = prod.display
    distDisplay = _.find(prod.versionTypes, (dist)->
      dist.name is config.dist
    ).display

    $scope.chartConfig = chartsProvider.chartTrend {
        title: "#{config.days}天缺陷趋势图"
        subtitle: "#{prodDisplay} - #{distDisplay}"
      }, trend

).controller("productDistributionCtrl", ($scope, config, distribution, products, chartsProvider) ->
  if distribution
    prod = _.find(products, (prod)->
      prod.name is config.product
    )
    prodDisplay = prod.display
    distDisplay = _.find(prod.versionTypes, (dist)->
      dist.name is config.dist
    ).display
    categoryDisplay = switch config.category
      when "tag" then "类型"
      when "app" then "应用"

    $scope.chartConfig = chartsProvider.chartDistribution {
        title: "#{config.days}天缺陷分布图"
        subtitle: "#{prodDisplay} - #{categoryDisplay} - #{distDisplay}"
        totalDisplay: config.totalDisplay or 12
      }, distribution

).controller("productErrorRateCtrl", ($scope, config, errorRate, products, chartsProvider) ->
  if errorRate
    prod = _.find(products, (prod)->
      prod.name is config.product
    )
    prodDisplay = prod.display
    distDisplay = _.find(prod.versionTypes, (dist)->
      dist.name is config.dist
    ).display

    $scope.chartConfig = chartsProvider.chartRate {
        title: "总错误率（错误数/设备/天）"
        subtitle: "#{prodDisplay} - #{distDisplay}"
        drilldown:
          type: "pie"
          enabled: config.drilldown
          max: config.totalDrilldown
      }, errorRate
).controller("productErrorRateOfTagCtrl", ($scope, config, errorRateOfTag, products, chartsProvider) ->
  if errorRateOfTag
    seriesData = for data in errorRateOfTag
      [data.version, if data.devices is 0 then 0 else data.occurred*100/data.devices]
    seriesData = (d for d in seriesData by -1)
    prod = _.find(products, (prod)->
      prod.name is config.product
    )
    prodDisplay = prod.display
    distDisplay = _.find(prod.versionTypes, (dist)->
      dist.name is config.dist
    ).display
    $scope.chartConfig = chartsProvider.chartRateWithTotal {
      title: "重启率/天 - #{config.tag}"
      subtitle: "#{prodDisplay} - #{distDisplay}"
    }, errorRateOfTag
).controller("productErrorRateOfAppCtrl", ($scope, config, errorRateOfApp, products, chartsProvider) ->
  if errorRateOfApp
    prod = _.find(products, (prod)->
      prod.name is config.product
    )
    prodDisplay = prod.display
    distDisplay = _.find(prod.versionTypes, (dist)->
      dist.name is config.dist
    ).display

    $scope.chartConfig = chartsProvider.chartRate {
      title: "错误率/设备/天 - #{config.app}"
      subtitle: "#{prodDisplay} - #{distDisplay}"
      percentage: true
      drilldown:
        type: "pie"
        enabled: config.drilldown
        max: config.totalDrilldown
    }, errorRateOfApp
)