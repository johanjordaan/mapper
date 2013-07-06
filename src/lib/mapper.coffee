if !define?
	define = require('amdefine')(module) 


define [], () ->
	# Save the object to a persistent store
	#
	save = (map,obj,saver,callback) ->
		''	
	

	# Load the object from a persistent store
	#
	load = (map,key,loader,callback) ->
		obj = loader map,key


	# Update an existing object based on a source and a map
	# 
	update = (map,obj,source) ->	
		if !obj?
			obj = {}

		if !source?
			source = {}
	
		if !source.id?
			source.id = -1	

		obj.id = source.id
		
		# Copy all the relevant fields from the source to the obj
		#
		for field_name,field_def of map.fields 
			if field_name in Object.keys source
				if field_def.type == 'Simple'
					if field_def.conversion?
						obj[field_name] = field_def.conversion source[field_name]
					else
						obj[field_name] = source[field_name]
				else if field_def.type == 'List'
					for item in source[field_name]
						obj[field_name] = [];
						obj[field_name].push update field_def.map,{},item
				else if field_def.type == 'Ref'
					obj[field_name] = update field_def.map,{},source[field_name]

		# Add the default values to the obj based on the map
		#
		for field_name,field_def of map.fields 
			if field_name not in Object.keys source
				if field_def.type == 'Simple'
					obj[field_name] = field_def.default_value			# Assuming that a conversion is not required for defaults
				else if field_def.type == 'List'
					obj[field_name] = [i for i in field_def.default_value]
				else if field_def.type == 'SimpleList'
					obj[field_name] = field_def.default_value.slice		# Assuming that a conversion is not required for defaults
				else if field_def.type == 'Ref'
					obj[field_name] = create field_def.map,field_def.default_value
	
		obj

	# Create a new object based on the given map and the initial data
	#	
	create = (map,initial_data) ->
		update map,{},initial_data

	exports = 
		load:load
		update:update
		create:create	


