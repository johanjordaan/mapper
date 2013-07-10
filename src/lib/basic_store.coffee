if !define?
	define = require('amdefine')(module) 


# This is a basic dictionary store
# 

define ['../lib/mapper','../lib/junction'], (mapper,junction) ->

	# Note : This is not guarenteed to generate unique id's 
	#
	_get_id = (store,map,obj,callback) ->
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


	_dehidrate = (map,obj,source) ->
		obj.id = source.id
		mapper.apply map,obj,source,actions = 
			'Simple' : (field_name,field_def,obj,source) ->
				if source[field_name]?
					obj[field_name] = source[field_name]
			'SimpleList' : (field_name,field_def,obj,source) ->
				if source[field_name]?
					obj[field_name] = source[field_name].toString()
			'Ref' : (field_name,field_def,obj,source) ->
				if source[field_name]?
					obj[field_name] = source[field_name].id
		obj
				
	_save = (store,map,obj,callback) ->
		# Dehidrate the simple fields into a new object to be stored into the store
		#
		saved_obj = _dehidrate map,{},obj


		obj_save_j = junction.create()

		# Save the simple object fields
		#
		store["#{map.model_name}:#{obj.id}"] = saved_obj

		# Add the object to the default collection
		#
		if !store[map.default_collection]?
			store[map.default_collection] = []

		store[map.default_collection].push obj.id

		# Create the list ref object
		#
		mapper.apply map,obj,{},actions = 
			'List' : (field_name,field_def,obj,source) ->
				if obj[field_name]?
					if !store["#{map.model_name}:#{obj.id}:#{field_name}"]?
						store["#{map.model_name}:#{obj.id}:#{field_name}"] = []
					for item in obj[field_name]
						store["#{map.model_name}:#{obj.id}:#{field_name}"].push item.id

		junction.finalise obj_save_j,() ->
			callback(obj)


	# Any object marked as external is excluded from the list since it is asseumd that
	# they are managed as part of some other map 
	#		
	_flatten = (map,obj,stack) ->
		if !stack?
			stack = []
		stack.push dict = 
			map:map
			obj:obj
		mapper.apply map,obj,{},actions =
			'List' : (field_name,field_def,obj,source) ->
				if field_def.internal 
					for item in obj[field_name]
						if item?
							_flatten field_def.map,item,stack
			'Ref' : (field_name,field_def,obj,source) ->
				if field_def.internal 
					if obj[field_name]?
						_flatten field_def.map,obj[field_name],stack

		return stack

	load = (store,map,key,callback) ->
		''

	save = (store,map,obj,callback) ->
		# Flatten the the object hierachy
		#
		flat_object_list = _flatten(map,obj) 

		# Get ID's for all object that do not have id's
		#
		id_j = junction.create()

		for obj_map in flat_object_list
			obj_map.obj.id ?= -1
			if obj_map.obj.id == -1
				junction.call id_j,_get_id,store,obj_map.map,obj_map.obj,(id) ->
					obj_map.obj.id = id

		junction.finalise id_j, () ->
			# Save all the objects now that they have id's
			# 	
			save_j = junction.create()

			for obj_map in flat_object_list
				# Need to chack here if object is internal or not
				junction.call save_j,_save,store,obj_map.map,obj_map.obj,(obj) ->

			junction.finalise save_j, () ->
				callback obj		

	remove = (store,map,obj,callback) ->
		''

	exports =
		_get_id:_get_id
		load:load
		save:save
		remove:remove
