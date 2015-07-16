'use strict'

angular.module("dbboardApp")
  .controller "LocationDistributionCtrl", ($scope, LocationStat) ->
    $scope.province =
      options:
        legend:
          enabled: false
        title:
          text: "各省占比"
        chart:
          type: 'bar'
        tooltip:
          formatter: ->
            "#{@point.category}:<br><b>#{@point.y.toFixed(4)} %</b>"          
          style:
            padding: 10,
            fontWeight: 'bold'
      series:[
        data: _.map(LocationStat.province, (item) ->
          item.percent * 100
        )
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
        max: 100
        title:
          text: '总占比'
          align: "high"
        labels:
          overflow: 'justify'
          rotation: -45
          formatter: ->
            "#{@value} %"
      xAxis:
        categories: _.map(LocationStat.province, (item) ->
          item.name
        )
      useHighStocks: false
      size:
        # width: 400
        height: 800

    $scope.city =
      options:
        legend:
          enabled: false
        title:
          text: "各城市占比"
        chart:
          type: 'bar'
        tooltip:
          formatter: ->
            "#{@point.category}:<br><b>#{@point.y.toFixed(4)} %</b>"          
          style:
            padding: 10,
            fontWeight: 'bold'
      series:[
        data: _.map(LocationStat.city, (item) ->
          item.percent * 100
        )[..20]
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
        max: 100
        title:
          text: '总占比'
          align: "high"
        labels:
          overflow: 'justify'
          rotation: -45
          formatter: ->
            "#{@value} %"
      xAxis:
        categories: _.map(LocationStat.city, (item) ->
          item.name
        )[..20]
      useHighStocks: false
      size:
        # width: 400
        height: 800
