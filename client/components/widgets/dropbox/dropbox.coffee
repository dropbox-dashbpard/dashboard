"use strict"

angular.module("widgets.dropbox", ["adf.provider", "dropbox", "highcharts-ng", "ngGrid"])
.value("rebootTags", ["SYSTEM_RESTART", "APANIC_CONSOLE"])
.provider("chartsProvider", ->
  @colors = colors =
    device: "#8888FF"
    error: "#FF8888"

  @labels = labels =
    deviceSum: "设备数"
    deviceTime: "设备天"
    errorSum: "错误数"
    errorRate: "错误率/设备/天"

  @nameMapping = nameMapping = 
    "com.baidu.map.location": "百度地图"
    "com.baidu.input": "百度输入法"
    "com.android.soundrecorder":  "录音机"
    "com.android.bluetooth": "蓝牙"
    "com.android.browser": "浏览器"
    "com.android.calendar": "日历"
    "com.android.certinstaller": "证书安装程序"
    "com.android.contacts": "联系人"
    "com.android.deskclock": "时钟"
    "com.android.keychain": "密匙链"
    "com.android.launcher": "启动器"
    "com.android.location.fused": "Fused Location"
    "com.android.music": "音乐"
    "com.android.packageinstaller": "应用包安装程序"
    "com.android.phone": "手机"
    "com.android.providers.calendar": "日历存储 "
    "com.android.providers.contacts": "联系人存储"
    "com.android.providers.downloads": "下载管理程序"
    "com.android.providers.downloads.ui": "下载"
    "com.android.providers.drm": "DRM保护内容存储"
    "com.android.providers.media": "媒体存储"
    "com.android.providers.settings": "设置存储"
    "com.android.providers.userdictionary": "User Dictionary"
    "com.android.provision": "com.android.provision"
    "com.android.quicksearchbox": "搜索"
    "com.android.settings": "设置"
    "com.android.sharedstoragebackup": "com.android.sharedstoragebackup"
    "com.android.shell": "Shell"
    "com.android.systemui": "系统用户界面"
    "com.android.vpndialogs": "VpnDialogs"
    "com.android.providers.applications": "应用包访问权限帮助程序"
    "android": "android系统"
    "com.svox.pico": "Pico TTS"
    "com.android.inputmethod.pinyin": "谷歌拼音输入法"
    "com.jrm.localmm": "UI-LocalMM"
    "com.android.motionelfdriver": "动感精灵"
    "com.sohu.inputmethod.sogoupad": "搜狗输入法"
    "com.dianping.v1:pushservice": "大众点评"
    "com.baidu.video:bdservice_v1": "百度视频"
    "com.antutu.ABenchMark:pushservice": "安兔兔"

  @keys = keys = {}

  findUniqueKey = (orgkey) ->
    return orgkey if orgkey not of keys
    for i in [0..1000] when "#{orgkey}#{i}" not of keys
      return "#{orgkey}#{i}"

  getDisplayDistSerialData = (distribution, totalDisplay) ->
    seriesData = for k, v of distribution
      [k, v]
    seriesData = _.sortBy seriesData, (data) ->
      -data[1]
    if seriesData.length > totalDisplay
      others = _.reduce seriesData[totalDisplay-1..], (memo, data) ->
          memo + data[1]
        , 0
      seriesData = seriesData[0...totalDisplay-1]
      seriesData.push(["其他", others])
    _.each seriesData, (data) ->
      name = data[0]
      if name is "/system/bin/mediaserver"
        console.log "nameMapping[#{name}] = #{nameMapping[name]}"
      if data[0] of nameMapping
        [keys[nameMapping[data[0]]], data[0]] = [data[0], nameMapping[data[0]]]
      else if m = /([\w:$]+)$/g.exec(data[0])
        unikey = findUniqueKey m[0]
        keys[unikey] = data[0]
        data[0] = nameMapping[data[0]] = unikey

    return seriesData

  @$get = ->
    {
      chartTrend: (options, trend) ->
        seriesOccurred = []
        seriesDevice = []
        for k, v of trend
          date = new Date(Date.UTC(parseInt(k[0...4]), parseInt(k[4...6]) - 1, parseInt(k[6..])))
          seriesOccurred.push [date.getTime(), v.occurred]
          seriesDevice.push [date.getTime(), v.devices]

        {
          options:
            chart:
              type: "line"
          title:
            text: options.title
          subtitle:
            text: options.subtitle
          xAxis:
            type: "datetime"
            labels:
              rotation: -45
              align: "right"
              x: 10
            dateTimeLabelFormats:
              day: '%e. %b'
          yAxis: [
            title:
              text: labels.errorSum
              x: -15
              style:
                color: colors.error
            labels:
              align: 'left'
              x: -20
              style:
                color: colors.error
            min: 0
          ,
            title:
              text: labels.deviceSum
              x: 15
              style:
                color: colors.device
            labels:
              align: 'right'
              x: 10
              style:
                color: colors.device
            opposite: true
            min: 0
          ]
          series: [
            name: labels.errorSum
            data: seriesOccurred
            color: colors.error
          ,
            name: labels.deviceSum
            yAxis: 1
            data: seriesDevice
            color: colors.device
          ]
        }

      chartDistribution: (options, distribution) ->
        seriesData = getDisplayDistSerialData(distribution, options.totalDisplay)

        {
          title:
            text: options.title
          subtitle:
            text: options.subtitle
          options:
            tooltip:
              formatter: ->
                key = if @key of keys then keys[@key] else @key
                "<b>#{key}</b><br>总数: <b>#{@point.y.toLocaleString()}</b> #{@series.name}: <b>#{@point.percentage.toFixed(2)}%</b>"
          series: [
            type: "pie"
            name: "分布占比"
            data: seriesData
          ]
        }

      chartRate: (options, errorRate) ->
        seriesData = []
        totalSeriesData = []
        for data in errorRate
          seriesData.push {
            name: data.version
            y: if data.devices is 0 then 0 else data.occurred*(if options.percentage then 100 else 1)/data.devices
            drilldown: if options.drilldown?.enabled then data.version else null
          }
          totalSeriesData.push {
            name: data.version
            y: data.devices
          }
        drilldownSeries = if options.drilldown?.enabled
          for data in errorRate
            id: data.version
            name: data.version
            type: options.drilldown?.type or "column"
            data: getDisplayDistSerialData(data.drilldown or {}, options.drilldown.max or 12)
        else
          []

        {
          title:
            text: options.title

          subtitle:
            text: options.subtitle

          options:
            chart:
              type: "column"
            tooltip:
              formatter: ->
                if @series.name is labels.errorRate
                  if options.percentage
                    "<b>#{@point.y.toFixed(4)} %</b> #{@series.name}"
                  else
                    "<b>#{@point.y.toFixed(4)}</b> #{@series.name}"
                else if @series.name is labels.deviceTime
                  "总共 <b>#{@point.y.toLocaleString()}</b> #{@series.name}"
                else
                  key = if @key of keys then keys[@key] else @key
                  if options.drilldown?.type is "pie"
                    "<b>#{@series.name}</b><br/><b>#{key}</b><br/>总数：<b>#{@point.y.toLocaleString()}</b><br/>占比：<b>#{@point.percentage.toFixed(2)}%</b>"
                  else
                    "<b>#{@series.name}</b><br/><b>#{key}</b><br/>总数：<b>#{@point.y.toLocaleString()}</b>"
            drilldown:
              series: drilldownSeries

          xAxis:
            type: "category"
            labels:
              rotation: -45
          yAxis: [
              title:
                text: labels.errorRate
                x: -15
                style:
                  color: colors.error
              labels:
                formatter: ->
                  if options.percentage
                    "#{@value} %"
                  else
                    "#{@value}"
                align: 'left'
                x: -20
                style:
                  color: colors.error
              min: 0
            ,
              title:
                text: labels.deviceTime
                x: 15
                style:
                  color: colors.device
              labels:
                align: 'right'
                x: 10
                style:
                  color: colors.device
              opposite: true
              min: 0
            ]

          series: [
            type: "column"
            name: labels.errorRate
            data: seriesData
            color: colors.error
            dataLabels:
              enabled: true
              # rotation: -90
              align: "center"
              formatter: ->
                if options.percentage
                  "#{@point.y.toFixed(2)} %"
                else
                  "#{@point.y.toFixed(2)}"
              style:
                fontSize: "10px"
          ,
            type: "line"
            name: labels.deviceTime
            yAxis: 1
            data: totalSeriesData
            color: colors.device
          ]
        }

      chartRateWithTotal: (options, errorRate) ->
        categories = for data in errorRate
          data.version
        rate = for data in errorRate
          if data.devices is 0 then 0 else data.occurred*100/data.devices
        total = for data in errorRate
          data.devices

        {
          title:
            text: options.title
          subtitle:
            text: options.subtitle
          options:
            tooltip:
              formatter: ->
                if @series.name is labels.errorRate
                  "<b>#{@point.y.toFixed(2)}%</b> #{@series.name}"
                else
                  "总共 <b>#{@point.y.toLocaleString()}</b> #{@series.name}"
          xAxis:
            categories: categories
            labels:
              rotation: -45
          yAxis: [
            title:
              text: labels.errorRate
              x: -15
              style:
                color: colors.error
            labels:
              formatter: ->
                "#{@value} %"
              align: 'left'
              x: -20
              style:
                color: colors.error
            min: 0
          ,
            title:
              text: labels.deviceTime
              x: 15
              style:
                color: colors.device
            labels:
              align: 'right'
              x: 10
              style:
                color: colors.device
            opposite: true
            min: 0
          ]

          series: [
            type: "column"
            name: labels.errorRate
            data: rate
            color: colors.error
          ,
            type: "line"
            name: labels.deviceTime
            yAxis: 1
            data: total
            color: colors.device
          ]
        }
    }

  return @
)
