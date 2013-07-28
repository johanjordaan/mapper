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
    $resource '/models'

    #, {}, 
    #  get: 
    #    method:'GET'
    #    params:
    #      phoneId:'phones'
    #    isArray:true

  module.config ($routeProvider) ->
    
    $routeProvider.when '/',
      controller  : ListCtrl
      templateUrl : 'list'

    $routeProvider.when '/new',
      controller  : CreateCtrl
      templateUrl : 'detail'

    $routeProvider.otherwise 
      redirectTo : '/'  
  
  @ListCtrl = ($scope,Models) ->
    Models.query (data) ->
      $scope.models = data

  @CreateCtrl = ($scope,$location,Models) ->
    $scope.save = () ->
      Models.save $scope.model
      $location.path '/'

  angular.bootstrap document, ['myApp']
