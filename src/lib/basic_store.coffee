if !define?
	define = require('amdefine')(module) 


# This is a basic dictionary store
# 

define ['../lib/mapper'], (mapper) ->

	# Note : This is not guarenteed to generate unique id's 
	#
	get_id = (store,map,obj,callback) ->
		# If the map defineds an id field then us the value of the id field rather than an generated id
		#
		if map.id_field?
			callback obj[map.id_field]
			return
		
		# Create the ID tracker if it des not exist
		#	
		if !store[map.model_name]?
			store[map.model_name] = 0	

		# Increment the id and return it
		#
		store[map.model_name]++ 	

		callback(store[map.model_name])


	load = (store,map,key,callback) ->
		''

	_save = (store,map,obj,callback) ->
		# Create a new object to store in the store
		#
		saved_obj = mapper.update map,{},obj
		store["#{map.model_name}:#{obj.id}"] = saved_obj

		# If the collectiodn does not exist then create a new one
		#
		if !store[map.default_collection]?
			store[map.default_collection] = []


		store[map.default_collection].push saved_obj.id

		callback(saved_obj)
		
	save = (store,map,obj,callback) ->
		obj.id ?= -1

		if obj.id == -1
			get_id store,map,obj,(id) ->
				obj.id = id
				_save store,map,obj,callback
		else
			_save store,map,obj,callback


	exports =
		get_id:get_id	
		load:load
		save:save