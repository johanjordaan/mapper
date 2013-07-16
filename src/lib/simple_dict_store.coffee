if !define?
    define = require('amdefine')(module) 


# This is a basic dictionary store
# 

define ['../lib/mapper','../lib/junction'], (mapper,junction) ->

    # Note : This is not guarenteed to generate unique id's 
    #
    _get_id = (store,map,obj,callback) ->
        # If the map defineds an id field then us the value of the id field rather than an generated id
        
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
                        _flatten field_def.map,item,stack
            'Ref' : (field_name,field_def,obj,source) ->
                if field_def.internal 
                    if obj[field_name]?
                        _flatten field_def.map,obj[field_name],stack

        return stack

    _load = (j,store,map,key,callback) ->
        ret_val = {}
        db_item = store["#{map.model_name}:#{key}"]
        if db_item?
            ret_val = {id:key}
            mapper.apply map,ret_val,db_item,action =
                'Simple' : (field_name,field_def,obj,source) ->
                    if source?
                        obj[field_name] = source[field_name]
                'SimpleList' :  (field_name,field_def,obj,source) ->
                    obj[field_name] = source[field_name].split ','
                'List' :  (field_name,field_def,obj,source) ->
                    list = store["#{map.model_name}:#{key}:#{field_name}"]
                    obj[field_name] = []
                    for item in list
                        junction.call j,_load,j,store,field_def.map,item,(loaded_obj) ->  
                            obj[field_name].push loaded_obj
                'Ref' : (field_name,field_def,obj,source) ->
                    # TODO : Ref fields should not be loaded multiple times.
                    if source[field_name]?
                        junction.call j,_load,j,store,field_def.map,source[field_name],(loaded_obj) ->  
                            obj[field_name] = loaded_obj
        callback ret_val

    load = (store,map,key,callback) ->
        load_j = junction.create()

        obj = {}
        junction.call load_j,_load,load_j,store,map,key,(loaded_obj) ->
            obj = loaded_obj

        junction.finalise load_j,(stuff) ->
            callback obj        

    # objects is a list of dictionaries [{obj:,map:}...]
    save_all = (store,objects,callback) ->
        save_all_j = junction.create()

        for obj_map in objects
            junction.call save_all_j,save,store,obj_map.map,obj_map.obj,() ->
                obj_map.obj

        junction.finalise save_all_j, (objects) ->
            callback objects


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
                junction.call save_j,_save,store,obj_map.map,obj_map.obj,(obj) ->

            junction.finalise save_j, () ->
                callback obj        

    remove = (store,map,obj,callback) ->
        ''

    get_id : (ctx,model_name,callback) ->
        ' Assume ctx is the actual store, for other implimentations this will be the connection?'
        'return an id based on the underlying stores mechanism, key here can be a table in atraditional db'
        'get_id Person,cb(id)'
        # Create the ID tracker if it des not exist
        #   
        if !ctx[model_name]?
            store[model_name] = 0   

        # Increment the id and return it
        #
        ctx[model_name]++     

        callback(ctx[map.model_name])

    save : (ctx,model_name,key,obj,callback) ->
        'save Person,1??,{id:1},cb,cb(saved_person)'
        'store the obj under the key'
        # Save the simple object fields
        #
        ctx["#{model_name}:#{key}"] = obj

    load : (ctx,model_name,key,callback) ->
        'load Person,1,cb(loaded_person)'
        'load the obj under the key'
        
    #save_link : (parent_model_name,parent_key,child_model_name,[list_of_ids**??or objects],cb(??)) ->
    #    'link fk refs to the obj'
    #    'save_link Person,1,accounts,[accounts],cb(??)'    
    #load_link : (parent_model_name,parent_key,child_model_name,cb(listof ids** or objects??)) ->
    #    'load_link Person,1,accounts,cb([])'



    exports =
        get_id:get_id
        load:load
        load_link:load_link
        save:save
        save_link:save_link
        remove:remove

