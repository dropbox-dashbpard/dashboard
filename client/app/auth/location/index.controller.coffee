'use strict'

angular.module("dbboardApp")
  .controller "LocationDistributionCtrl", ($scope, LocationDistribution, $timeout) ->

    chartOptions = (product, stats, prop, propName) ->
      options:
        legend:
          enabled: false
        title:
          text: "各#{propName}占比(#{product or '所有产品'})"
        chart:
          type: 'bar'
        tooltip:
          formatter: ->
            "#{@point.category}:<br><b>#{@point.y.toFixed(4)} %</b>"          
          style:
            padding: 10,
            fontWeight: 'bold'
      series:[
        data: _.map(stats[prop], (item) ->
          item.percent * 100
        )[..40]
        dataLabels:
          enabled: true
          align: "high"
          formatter: ->
            "#{@point.y.toFixed(2)} %"
          style:
            fontSize: "10px"
      ]
      plotOptions:
        bar:
          dataLabels:
            enabled: true
      yAxis:
        title:
          text: '总占比'
          align: "high"
        labels:
          overflow: 'justify'
          rotation: -45
          formatter: ->
            "#{@value} %"
      xAxis:
        categories: _.map(stats[prop], (item) ->
          item.name
        )[..40]
      useHighStocks: false
      size:
      #   # width: 400
        height: 800

    nextProduct = do ->
      index = 0
      ->
        while index < $scope.products.length
          if $scope.products[index]?.versions?.production?.length > 0
            return $scope.products[index++].name
          index += 1
        index = 0
        null

    update = ->
      prod = do nextProduct
      LocationDistribution.query {product: prod, days: 15}, (stats) ->
        $scope.country = chartOptions prod, stats, 'country', '国家'
        $scope.province = chartOptions prod, stats, 'province', '省份'
        $scope.city = chartOptions prod, stats, 'city', '城市'
        $scope.timer = $timeout update, 20 * 1000
    update()

    $scope.$on '$destroy', ->
      $timeout.cancel $scope.timer if $scope.timer?
