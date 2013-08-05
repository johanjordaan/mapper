if !define?
  define = require('amdefine')(module) 

define ['../lib/mapper','../lib/store','../lib/js_store','../lib/mapper_maps.js'], (mapper,store,js_store,mapper_maps) ->
  express = require 'express'
  http = require 'http' 
  path = require 'path'

  app = express()

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
  app.use(express.static(path.join(__dirname, 'public')));
  app.use(express.static(path.join(__dirname,'..', 'bower_components')));
  app.use(express.static(path.join(__dirname,'..', 'temp')));


  if ('development' == app.get('env'))
    app.use(express.errorHandler())

  local_store = {}  

  # Views
  #
  app.get '/', (req, res) ->
    res.render('index', { title: 'Express II' })

  app.get '/list', (req, res) ->
    res.render('list', { })

  app.get '/detail', (req, res) ->
    res.render('detail', { })

  # REST  
  #
  app.post '/models', (req,res) ->
    new_map = mapper.create mapper_maps.map_map,req.body
    store.save local_store,js_store,mapper_maps.map_map,new_map,(saved_map)->
      res.json(saved_map)   

  app.get '/models', (req,res) ->
    store.load_all local_store,js_store,mapper_maps.map_map,(loaded_maps) ->
      ##console.log loaded_maps
      res.json(loaded_maps)

  app.delete '/models', (req,res) ->
    console.log req.query.id
    res.json({})
      


  http.createServer(app).listen app.get('port'), () ->
    console.log('Express server listening on port ' + app.get('port'))

