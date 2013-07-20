if !define?
    define = require('amdefine')(module) 


define [], () ->
    # Apply the functions to the types
    #
    apply = (map,obj,source,actions,filter) ->
        for field_name,field_def of map.fields
            if actions[field_def.type]?
                if filter?
                    if filter field_name,field_def,obj,source
                        actions[field_def.type] field_name,field_def,obj,source
                else
                    actions[field_def.type] field_name,field_def,obj,source
        obj         

    # Any object marked as external is excluded from the list since it is asseumd that
    # they are managed as part of some other map 
    #       
    flatten = (map,obj,stack) ->
        if !stack?
            stack = []
        stack.push dict = 
            map:map
            obj:obj
        apply map,obj,{},actions =
            'List' : (field_name,field_def,obj,source) ->
                if field_def.internal 
                    for item in obj[field_name]
                        flatten field_def.map,item,stack
            'Ref' : (field_name,field_def,obj,source) ->
                if field_def.internal 
                    if obj[field_name]?
                        flatten field_def.map,obj[field_name],stack

        return stack


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
        apply map,obj,source,
            actions = 
                Simple : (field_name,field_def,obj,source) ->
                    if field_def.conversion?
                        obj[field_name] = field_def.conversion source[field_name]
                    else
                        obj[field_name] = source[field_name]
                List : (field_name,field_def,obj,source) ->
                    for item in source[field_name]
                        obj[field_name] = [];
                        obj[field_name].push update field_def.map,{},item
                Ref : (field_name,field_def,obj,source) ->
                    obj[field_name] = update field_def.map,{},source[field_name]
            ,(field_name,field_def,obj,source) ->
                field_name in Object.keys source 

        # Add the default values to the obj based on the map
        #
        for field_name,field_def of map.fields 
            if field_name not in Object.keys source
                if field_def.type == 'Simple'
                    obj[field_name] = field_def.default_value           # Assuming that a conversion is not required for defaults
                else if field_def.type == 'List'
                    obj[field_name] = [i for i in field_def.default_value]
                else if field_def.type == 'SimpleList'
                    obj[field_name] = field_def.default_value.slice     # Assuming that a conversion is not required for defaults
                else if field_def.type == 'Ref'
                    obj[field_name] = create field_def.map,field_def.default_value
    
        obj

    # Create a new object based on the given map and the initial data
    #   
    create = (map,initial_data) ->
        update map,{},initial_data


    exports = 
        apply:apply
        flatten:flatten
        update:update
        create:create

