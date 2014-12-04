"use strict"

angular.module("dbboardApp")
.controller "NavbarCtrl", ($scope, $location, dbProductService) ->
  dbProductService.get().then (products) ->
    $scope.menu = [
      {
        title: "产品"
        link: "#"
        align: "left"
        subitems: for prod in products
          title: prod.display
          link: "/product/#{prod.name}"
      }
      {
        title: "查询"
        link: "/query"
        align: "right"
      }
    ]
  $scope.isCollapsed = false

  $scope.isActive = (route) ->
    $location.path().indexOf(route) is 0

  $scope.hasSubmenu = (item) ->
    console.log item
    item.subitems