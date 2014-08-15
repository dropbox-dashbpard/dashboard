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

###
@ngdoc directive
@name adf.directive:adfDashboard
@element div
@restrict ECA
@scope
@description

`adfDashboard` is a directive which renders the dashboard with all its
components. The directive requires a name attribute. The name of the
dashboard can be used to store the model.
###
"use strict"
angular.module("adf").directive "adfDashboard", ($rootScope, $log, $modal, dashboard) ->
  copyWidgets = (source, target) ->
    if source.widgets and source.widgets.length > 0
      w = source.widgets.shift()
      while w
        target.widgets.push w
        w = source.widgets.shift()
    return
  fillStructure = (model, columns, counter) ->
    angular.forEach model.rows, (row) ->
      angular.forEach row.columns, (column) ->
        column.widgets = []  unless column.widgets
        if columns[counter]
          copyWidgets columns[counter], column
          counter++
        return

      return

    counter
  readColumns = (model) ->
    columns = []
    angular.forEach model.rows, (row) ->
      angular.forEach row.columns, (col) ->
        columns.push col
        return

      return

    columns
  changeStructure = (model, structure) ->
    columns = readColumns(model)
    model.rows = structure.rows
    counter = 0
    counter = fillStructure(model, columns, counter)  while counter < columns.length
    return
  createConfiguration = (type) ->
    cfg = {}
    config = dashboard.widgets[type].config
    cfg = angular.copy(config)  if config
    cfg
  replace: true
  restrict: "EA"
  transclude: false
  scope:
    structure: "@"
    name: "@"
    collapsible: "@"
    adfModel: "="

  controller: ($scope) ->
    
    # sortable options for drag and drop
    $scope.sortableOptions =
      connectWith: ".column"
      handle: ".fa-arrows"
      cursor: "move"
      tolerance: "pointer"
      placeholder: "placeholder"
      forcePlaceholderSize: true
      opacity: 0.4

    name = $scope.name
    model = $scope.adfModel
    if not model or not model.rows
      structureName = $scope.structure
      structure = dashboard.structures[structureName]
      if structure
        if model
          model.rows = angular.copy(structure).rows
        else
          model = angular.copy(structure)
        model.structure = structureName
      else
        $log.error "could not find structure " + structureName
    if model
      model.title = "Dashboard"  unless model.title
      $scope.model = model
    else
      $log.error "could not find or create model"
    
    # edit mode
    $scope.editMode = false
    $scope.editClass = ""
    $scope.toggleEditMode = ->
      $scope.editMode = not $scope.editMode
      if $scope.editClass is ""
        $scope.editClass = "edit"
      else
        $scope.editClass = ""
      $rootScope.$broadcast "adfDashboardChanged", name, model  unless $scope.editMode
      return

    
    # edit dashboard settings
    $scope.editDashboardDialog = ->
      editDashboardScope = $scope.$new()
      editDashboardScope.structures = dashboard.structures
      instance = $modal.open(
        scope: editDashboardScope
        templateUrl: "components/adf/templates/dashboard-edit.html"
      )
      $scope.changeStructure = (name, structure) ->
        $log.info "change structure to " + name
        changeStructure model, structure
        return

      editDashboardScope.closeDialog = ->
        instance.close()
        editDashboardScope.$destroy()
        return

      return

    
    # add widget dialog
    $scope.addWidgetDialog = ->
      addScope = $scope.$new()
      addScope.widgets = dashboard.widgets
      opts =
        scope: addScope
        templateUrl: "components/adf/templates/widget-add.html"

      instance = $modal.open(opts)
      addScope.addWidget = (widget) ->
        w =
          type: widget
          config: createConfiguration(widget)

        addScope.model.rows[0].columns[0].widgets.unshift w
        instance.close()
        addScope.$destroy()
        return

      addScope.closeDialog = ->
        instance.close()
        addScope.$destroy()
        return

      return

    return

  link: ($scope, $element, $attr) ->
    
    # pass attributes to scope
    $scope.name = $attr.name
    $scope.structure = $attr.structure
    return

  templateUrl: "components/adf/templates/dashboard.html"

