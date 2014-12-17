'use strict'

angular.module 'dbboardApp'
.controller 'UserCtrl', ($scope, $http, $modal, UserModel) ->
  $scope.users = UserModel.query()
  
  $scope.open = (user, create=false) ->
    modalInstance = $modal.open
      templateUrl: 'UserEdit.html'
      controller: 'UserEditCtrl'
      resolve:
        user: ->
          user
        session: ->
          $scope.session
    modalInstance.result.then (user) ->
      if user.password?.length is 0
        delete user.password
      user.$save()
      if create
        $scope.users = UserModel.query()
    , (user) ->
      if create
        user.$get()
  
  $scope.remove = (user) ->
    user.$remove()
    $scope.users = UserModel.query()
  
  $scope.add = ->
    $scope.open new UserModel(
      username: 'name'
      email: 'name@email.com'
      guest: not $scope.session.user.admin
    ), true
.controller 'UserEditCtrl', ($scope, $modalInstance, user, session) ->
  $scope.user =
    username: user.username
    email: user.email
    name: user.name or ""
    admin: user.admin or false
    groupadmin: not user.guest
    group: user.group
    password: ''
  $scope.session= session
  $scope.ok = ->
    user.username = $scope.user.username
    user.email = $scope.user.email
    user.name = $scope.user.name
    user.admin = $scope.user.admin
    user.group = $scope.user.group
    user.guest = not $scope.user.groupadmin
    if $scope.user.password.length > 0
      user.password = $scope.user.password
    $modalInstance.close(user)
  $scope.cancel = ->
    $modalInstance.dismiss(user)
