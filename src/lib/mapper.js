if(typeof(require) == 'undefined') {
} else {
	_ = require('underscore');
	redis = require('redis');
	printf = require('../utils/printf.js').printf;
	construct = require('../utils/constructor.js').construct;
	Junction = require('../utils/junction.js').Junction;
	util = require('util');
}
// Redis wrappers
//
var incr = function(client,name,callback) {
	client.incr(name,callback);	
}
var hset = function(client,key,field,val,callback) {
	client.hset(key,field,val,callback);
}
var hget = function(client,key,field,callback) {
	client.hget(key,field,callback);
}
var sadd = function(client,key,val,callback) {
    client.sadd(key,val,callback);
}
var smembers = function(client,key,callback) {
	client.smembers(key,callback);
}





var make_key = function(name,id,field_name) {
	var key;
	if(_.isUndefined(field_name)) {
		key = util.format('%s:%s',name,id);
	} else {
		key = util.format('%s:%s:%s',name,id,field_name);
	}
	return key;
}


var Mapper = function(db_id,client_count) {
	if(_.isUndefined(db_id))
		this.db_id = 0;
	else
		this.db_id = db_id;

	if(_.isUndefined(client_count))
		this.client_count = 1;
	else
		this.client_count = client_count;

		
	this.clients = [];
	for(var i=0;i<this.client_count;i++) {
		var c = redis.createClient();
		c.select(this.db_id);
		this.clients.push(c);
	}
	this.current_client = 0;
}

Mapper.prototype._get_client = function() {
	this.current_client = this.current_client +1;
	if(this.current_client>=this.client_count) {
		this.current_client = 0;
	}
	return this.clients[this.current_client];
}

Mapper.prototype.quit = function() {
	_.each(this.clients,function(client){
		client.quit();
	});
}


Mapper.prototype._all = function(map,obj,stack) {
	var that = this;
	if(_.isUndefined(stack)) stack = [];
	stack.push({obj:obj,map:map});

	_.each(map.fields,function(field,field_name) {
		if(field.type == 'Ref') {
			that._all(field.map,obj[field_name],stack);
		} else if(field.type == 'List') {
			_.each(obj[field_name],function(child) {
				that._all(field.map,child,stack);
			});
		}
	});	
	
	return stack;
} 

Mapper.prototype.save = function(map,obj,callback) {
	var that = this;
	var j = new Junction();
	var all_objects = that._all(map,obj)
	_.each(all_objects,function(current_object) {
		if(_.isUndefined(current_object.obj.id) || current_object.obj.id == -1) {
			if(_.isUndefined(current_object.map.id_field)) {
				j.call(incr,that._get_client(),current_object.map.model_name,function(err,id){
					current_object.obj.id = id;
				});
			} else {
				current_object.obj.id = current_object.obj[current_object.map.id_field];
			}
		}
	});
	j.finalise(function() {
		var j2 = new Junction();
		
		_.each(all_objects,function(current_object){
			var object_key = current_object.map.model_name+':'+current_object.obj.id;
			_.each(current_object.map.fields,function(field,field_name){
				if(field.type == 'Simple') {
					j2.call(hset,that._get_client(),object_key,field_name,current_object.obj[field_name],function(){});
				} else if(field.type == 'SimpleList') { 
					j2.call(hset,that._get_client(),object_key,field_name,current_object.obj[field_name].toString(),function(){});
				} else if(field.type == 'Ref') {
					j2.call(hset,that._get_client(),object_key,field_name,current_object.obj[field_name].id,function(){});
				} else if(field.type == 'List') {
					_.each(current_object.obj[field_name],function(child){
						j2.call(sadd,that._get_client(),object_key+':'+field_name,child.id,function() {});
					});
				}
			});
			
			if(!_.isUndefined(current_object.map.default_collection)) {
				j2.call(sadd,that._get_client(),current_object.map.default_collection,current_object.obj.id,function() {});	
			}
		});
		
		j2.finalise(function(){
			callback(obj);
		});
	});
}

Mapper.prototype.save_all = function(map,obj_list,callback) {
	var that = this;
	
	var saved_obj_list = [];
	var j = new Junction();
	
	_.each(obj_list,function(obj) { 
		j.call(that,'save',map,obj,function(obj) {
			saved_obj_list.push(obj);
		});
	});
	
	j.finalise(function() { 
		callback(saved_obj_list);
	});
	
}




Mapper.prototype._load = function(map,id,j,callback) {
    var that = this;
    
    var obj = this.create(map);
    obj.id = id;
	var object_key = map.model_name+':'+obj.id;
	
     _.each(map.fields,function(field,field_name) {
		if(field.type == 'Simple') {
			j.call(hget,that._get_client(),object_key,field_name,function(err,val){
				if(!_.isUndefined(field.conversion))
					obj[field_name] = field.conversion(val);
				else
					obj[field_name] = val;
			});
		} else if(field.type == 'SimpleList') { 
			j.call(hget,that._get_client(),object_key,field_name,function(err,val){
				if(!_.isUndefined(field.conversion))
					obj[field_name] = _.map(val.split(','),field.conversion);
				else
					obj[field_name] = val.split(',');
			});
		} else if(field.type == 'Ref'){
			j.call(hget,that._get_client(),object_key,field_name,function(err,child_id){
				that._load(field.map,parseInt(child_id),j,function(ref_obj){
					obj[field_name] = ref_obj;
				});
			});
		} else if(field.type == 'List'){
			j.call(smembers,that._get_client(),object_key+':'+field_name,function(err,child_ids){
				_.each(child_ids,function(child_id){
					that._load(field.map,parseInt(child_id),j,function(child_obj){
						obj[field_name].push(child_obj);
					});
				});
			});
		}		
	});
	callback(obj);		// This callback seems to be a bit out of place ... Maybe it needs to be dropped totally? 
	                    // It is used to invoke the junction finalise
}


Mapper.prototype.load = function(map,id,callback) {
	if(_.isUndefined(map)) throw 'Map not provided for load.';
	if(_.isUndefined(id)) throw 'ID not provided for load.';
    var that = this;

	var j = new Junction();
	var obj = null;
	this._load(map,id,j,function(obj) {
		j.finalise(function(){
			// Call the constructor for each class that requires it to be called
			//
			_.each(that._all(map,obj),function(current_obj){
				_.each(current_obj.map.call_after_load,function(after_load_func) {
					after_load_func(current_obj.obj);
				});
			});
			callback(obj);
		});
	}); 
}

Mapper.prototype.load_all = function(map,callback) {
	var that = this;

	var loaded_obj_list = [];
	if(_.isUndefined(map.default_collection)) {
		callback(loaded_obj_list);
		return;
	}
	smembers(that._get_client(),map.default_collection,function(err,obj_ids) {
		var j = new Junction();
		_.each(obj_ids,function(id){
			
			j.call(that,'load',map,id,function(loaded_obj){
				loaded_obj_list.push(loaded_obj);
			})
		});
		j.finalise(function(){
			callback(loaded_obj_list);
		})
	});
}

var _update = function(map,dest,source) {
	if(_.isUndefined(source))
		source = {};
	
	if(_.isUndefined(source.id))
		source.id  = -1;

	dest.id = source.id;
		
	_.each(map.fields, function(field_def,field_name) {
		if(field_name in source) {
			if(field_def.type == 'Simple') {
				if(_.isUndefined(field_def.conversion))
					dest[field_name] = source[field_name];
				else
					dest[field_name] = field_def.conversion(source[field_name]);
			} else if(field_def.type == 'List') {
				_.each(source[field_name],function(item){
					dest[field_name] = [];
					var new_obj = {}
					if(!_.isUndefined(field_def.map.cls))
						new_obj = new field_def.map.cls();
					dest[field_name].push(_update(field_def.map,new_obj,item));
				});
			} else if(field_def.type == 'Ref') {
				var new_obj = {}
				if(!_.isUndefined(field_def.map.cls))
					new_obj = new field_def.map.cls(map);
				dest[field_name] = _update(field_def.map,new_obj,source[field_name]);
			}
		} 
	});
	
	_add_defaults(map,dest);
	
	return dest;
}


Mapper.prototype.update = function(map,dest,source) {
	return _update(map,dest,source);	
}

var _add_defaults = function(map,obj) {
	var that = this;
	_.each(map.fields, function(field_def,field_name) {
		if(_.has(obj,field_name)) {
		} else {
			if(field_def.type == 'Simple') 
				obj[field_name] = field_def.default_value;		// Assuming that a conversion is not required for defaults
			else if(field_def.type == 'SimpleList') {
				obj[field_name] = field_def.default_value.slice();		// Assuming that a conversion is not required for defaults
			}
			else if(field_def.type == 'List')
				obj[field_name] = [];
			else if(field_def.type == 'Ref') {
				if(field_def.internal)
					obj[field_name] = _create(field_def.map);
			}
		}
	});
	return obj;
}

var _create = function(map,initial_data) {
	var new_obj = {};
	if(!_.isUndefined(map.cls))
		new_obj = new map.cls(map);
	
	_update(map,new_obj,initial_data)
	
	return new_obj;
} 

Mapper.prototype.create = function(map,initial_data) {
	return _create(map,initial_data);
} 


if(typeof module != 'undefined') {
    module.exports.Mapper = Mapper;
	module.exports.update = _update;
	module.exports.create = _create;
} else {
    mapper = {
		update : _update,
		create : _create
	}
}