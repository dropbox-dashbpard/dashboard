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

angular.module("adf").directive "adfWidget", ($log, $modal, dashboard) ->
  preLink = ($scope, $element, $attr) ->
    definition = $scope.definition
    if definition
      w = dashboard.widgets[definition.type]
      if w
        
        # pass title
        definition.title = w.title  unless definition.title
        
        # pass edit mode
        $scope.editMode = $attr.editMode
        
        # pass copy of widget to scope
        $scope.widget = angular.copy(w)
        
        # create config object
        config = definition.config
        if config
          config = angular.fromJson(config)  if angular.isString(config)
        else
          config = {}
        
        # pass config to scope
        $scope.config = config
        
        # collapse
        $scope.isCollapsed = false
      else
        $log.warn "could not find widget " + type
    else
      $log.debug "definition not specified, widget was probably removed"
    return
  postLink = ($scope, $element, $attr) ->
    definition = $scope.definition
    if definition
      
      # bind close function
      $scope.close = ->
        column = $scope.col
        if column
          index = column.widgets.indexOf(definition)
          column.widgets.splice index, 1  if index >= 0
        $element.remove()
        return

      
      # bind reload function
      $scope.reload = ->
        $scope.$broadcast "widgetReload"
        return

      
      # bind edit function
      $scope.edit = ->
        editScope = $scope.$new()
        opts =
          scope: editScope
          templateUrl: "components/adf/templates/widget-edit.html"

        instance = $modal.open(opts)
        editScope.closeDialog = ->
          instance.close()
          editScope.$destroy()
          widget = $scope.widget
          
          # reload content after edit dialog is closed
          $scope.$broadcast "widgetConfigChanged"  if widget.edit and widget.edit.reload
          return

        return
    else
      $log.debug "widget not found"
    return
  replace: true
  restrict: "EA"
  transclude: false
  templateUrl: "components/adf/templates/widget.html"
  scope:
    definition: "="
    col: "=column"
    editMode: "@"
    collapsible: "="

  compile: compile = ($element, $attr, transclude) ->
    
    ###
    use pre link, because link of widget-content
    is executed before post link widget
    ###
    pre: preLink
    post: postLink

