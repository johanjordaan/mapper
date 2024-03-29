// Generated by CoffeeScript 1.6.3
(function() {
  var define;

  if (typeof define === "undefined" || define === null) {
    define = require('amdefine')(module);
  }

  define(['../lib/mapper', '../lib/store', '../lib/js_store', '../lib/mapper_maps.js'], function(mapper, store, js_store, mapper_maps) {
    var app, express, http, local_store, path;
    express = require('express');
    http = require('http');
    path = require('path');
    app = express();
    app.set('port', process.env.PORT || 3000);
    app.set('views', __dirname + '/views');
    app.set('view engine', 'jade');
    app.use(express.favicon());
    app.use(express.logger('dev'));
    app.use(express.bodyParser());
    app.use(express.methodOverride());
    app.use(express.cookieParser('your secret here'));
    app.use(express.session());
    app.use(app.router);
    app.use(express["static"](path.join(__dirname, 'public')));
    app.use(express["static"](path.join(__dirname, '..', 'bower_components')));
    app.use(express["static"](path.join(__dirname, '..', 'temp')));
    if ('development' === app.get('env')) {
      app.use(express.errorHandler());
    }
    local_store = {};
    app.get('/', function(req, res) {
      return res.render('index', {
        title: 'Express II'
      });
    });
    app.get('/list', function(req, res) {
      return res.render('list', {});
    });
    app.get('/detail', function(req, res) {
      return res.render('detail', {});
    });
    app.post('/models', function(req, res) {
      var new_map;
      new_map = mapper.create(mapper_maps.map_map, req.body);
      return store.save(local_store, js_store, mapper_maps.map_map, new_map, function(saved_map) {
        return res.json(saved_map);
      });
    });
    app.get('/models', function(req, res) {
      return store.load_all(local_store, js_store, mapper_maps.map_map, function(loaded_maps) {
        return res.json(loaded_maps);
      });
    });
    app["delete"]('/models', function(req, res) {
      console.log(req.query.id);
      return res.json({});
    });
    return http.createServer(app).listen(app.get('port'), function() {
      return console.log('Express server listening on port ' + app.get('port'));
    });
  });

}).call(this);
