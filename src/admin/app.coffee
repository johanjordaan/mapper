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


app.get '/', (req, res) ->
  res.render('index', { title: 'Express II' })

app.get '/list', (req, res) ->
  res.render('list', { })

app.get '/models', (req,res) ->
  ret_val = [
    name : 'Planet'
    description : 'This is a planet model'
  ,
    name : 'Ship'
    description : 'This is a ship model'
  ] 
  console.log ret_val

  res.json(ret_val)   


http.createServer(app).listen app.get('port'), () ->
  console.log('Express server listening on port ' + app.get('port'))

