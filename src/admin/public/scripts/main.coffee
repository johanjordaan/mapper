requirejs.config
  shim :
    '/angular/angular.js' :
      exports : 'angular'
    '/angular-resource/angular-resource.js' :
      exports : 'angular_resource'
      deps : ['/angular/angular.js']


require ["/angular/angular.js","/angular-resource/angular-resource.js"], (angular,angular_resource) ->

  module = angular.module 'myApp',['ngResource']
  module.value 'some_value', ''

  module.factory 'Models', ($resource) ->
    $resource '/models', {}, 
      query: 
        method:'GET'
        params:
          phoneId:'phones'
        isArray:true

  module.config ($routeProvider) ->
    
    $routeProvider.when '/',
      controller  : ListCtrl
      templateUrl : 'list'
  
  @ListCtrl = ($scope,Models) ->
    #$scope.models = Models
    Models.query (data) ->
      $scope.models = data

    $scope.remove = (id) ->
      Models.pop()
    $scope.add = () ->
      Models.push({id:Models.length,name:"Some new model",description:"A description ..."})  


  angular.bootstrap document, ['myApp']
