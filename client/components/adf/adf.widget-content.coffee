#
# * The MIT License
# * 
# * Copyright (c) 2013, Sebastian Sdorra
# * 
# * Permission is hereby granted, free of charge, to any person obtaining a copy
# * of this software and associated documentation files (the "Software"), to deal
# * in the Software without restriction, including without limitation the rights
# * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# * copies of the Software, and to permit persons to whom the Software is
# * furnished to do so, subject to the following conditions:
# * 
# * The above copyright notice and this permission notice shall be included in
# * all copies or substantial portions of the Software.
# * 
# * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# * SOFTWARE.
# 
"use strict"
angular.module("adf").directive "adfWidgetContent", ($log, $q, $sce, $http, $templateCache, $compile, $controller, $injector, dashboard) ->
  getTemplate = (widget) ->
    deferred = $q.defer()
    if widget.template
      deferred.resolve widget.template
    else if widget.templateUrl
      url = $sce.getTrustedResourceUrl(widget.templateUrl)
      $http.get(url,
        cache: $templateCache
      ).success((response) ->
        deferred.resolve response
        return
      ).error ->
        deferred.reject "could not load template"
        return

    deferred.promise
  compileWidget = ($scope, $element) ->
    model = $scope.model
    content = $scope.content
    
    # display loading template
    $element.html dashboard.loadingTemplate
    
    # create new scope
    templateScope = $scope.$new()
    
    # pass config object to scope
    model.config = {}  unless model.config
    templateScope.config = model.config
    
    # local injections
    base =
      $scope: templateScope
      widget: model
      config: model.config

    
    # get resolve promises from content object
    resolvers = {}
    resolvers["$tpl"] = getTemplate(content)
    if content.resolve
      angular.forEach content.resolve, (promise, key) ->
        if angular.isString(promise)
          resolvers[key] = $injector.get(promise)
        else
          resolvers[key] = $injector.invoke(promise, promise, base)
        return

    
    # resolve all resolvers
    $q.all(resolvers).then ((locals) ->
      angular.extend locals, base
      
      # compile & render template
      template = locals["$tpl"]
      $element.html template
      if content.controller
        templateCtrl = $controller(content.controller, locals)
        $element.children().data "$ngControllerController", templateCtrl
      $compile($element.contents()) templateScope
      return
    ), (reason) ->
      
      # handle promise rejection
      msg = "Could not resolve all promises"
      msg += ": " + reason  if reason
      $log.warn msg
      $element.html dashboard.messageTemplate.replace(/{}/g, msg)
      return

    return
  replace: true
  restrict: "EA"
  transclude: false
  scope:
    model: "="
    content: "="

  link: ($scope, $element, $attr) ->
    compileWidget $scope, $element
    $scope.$on "widgetConfigChanged", ->
      compileWidget $scope, $element
      return

    $scope.$on "widgetReload", ->
      compileWidget $scope, $element
      return

    return

