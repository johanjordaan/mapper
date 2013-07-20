if !define?
    define = require('amdefine')(module) 


# This is a basic dictionary store
# 

define ['../lib/mapper','../lib/junction'], (mapper,junction) ->

    # Note : This is not guarenteed to generate unique id's 
    #
    get_id = (store,store_funcs,map,obj,callback) ->
        # If the map defineds an id field then us the value of the id field rather than an generated id
        
        if map.id_field?
            callback obj[map.id_field]
        else
            store_funcs.get_id store, map.model_name, callback

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

            
    _save = (store,store_funcs,map,obj,callback) ->
        # Dehidrate the simple fields into a new object to be stored into the store
        #
        saved_obj = _dehidrate map,{},obj

        # Create the list ref object
        #
        ref_list = {}
        mapper.apply map,obj,{},actions = 
            'List' : (field_name,field_def,obj,source) ->
                if obj[field_name]?
                    if !ref_list[field_name]?
                        ref_lits[field_name] = []
                    for item in obj[field_name]
                        ref_list[field_name].push item.id

        obj_save_j = junction.create()
        junction.call obj_save_j, store_funcs.save, store, map.model_name, obj
        junction.call obj_save_j, store_funcs.save_refs, store, map.model_name, obj, ref_list
        junction.call obj_save_j, store_funcs.add_to_collection, store, map.default_collection, obj   

        
        junction.finalise obj_save_j,() ->
            callback(obj)


    _load = (j,store,store_funcs,map,id,callback) ->
        ret_val = {}

        store_funcs.load map.model_name, id, (loaded_object) ->
            if loaded_object?
                # Get the list of ref fields
                #
                ref_field_names = []
                mapper.apply map,ret_val,loaded_object,actions =
                    'List' :  (field_name,field_def,obj,source) ->
                        ref_field_names.push field_name

                # Load the refs from db
                #
                store_funcs.load_refs store, model_name, id, ref_field_names, (ref_list) ->
                    ret_val = {id:id}
                    mapper.apply map,ret_val,loaded_object,actions =
                        'Simple' : (field_name,field_def,obj,source) ->
                            if source?
                                obj[field_name] = source[field_name]
                        'SimpleList' :  (field_name,field_def,obj,source) ->
                            obj[field_name] = source[field_name].split ','
                        'List' :  (field_name,field_def,obj,source) ->
                            list = ref_list[field_name]
                            obj[field_name] = []
                            for item in list
                                junction.call j, _load, j, store, store_funcs, field_def.map, item, (loaded_obj) ->  
                                    obj[field_name].push loaded_obj
                        'Ref' : (field_name,field_def,obj,source) ->
                            # TODO : Ref fields should not be loaded multiple times.
                            if source[field_name]?
                                junction.call j ,_load, j, store, store_funcs, field_def.map, source[field_name], (loaded_obj) ->  
                                    obj[field_name] = loaded_obj
                    callback ret_val

    load = (store,store_funcs,map,id,callback) ->
        load_j = junction.create()

        obj = {}
        junction.call load_j, _load, load_j, store, store_funcs, map, id, (loaded_obj) ->
            obj = loaded_obj

        junction.finalise load_j,(stuff) ->
            callback obj        

    # objects is a list of dictionaries [{obj:,map:}...]
    save_all = (store,store_funcs,objects,callback) ->
        save_all_j = junction.create()

        for obj_map in objects
            junction.call save_all_j, save, store, store_funcs, obj_map.map, obj_map.obj, () ->
                obj_map.obj

        junction.finalise save_all_j, (objects) ->
            callback objects


    save = (store,store_funcs,map,obj,callback) ->
        # Flatten the the object hierachy
        #
        flat_object_list = mapper.flatten map,obj 

        # Get ID's for all object that do not have id's
        #
        id_j = junction.create()

        for obj_map in flat_object_list
            obj_map.obj.id ?= -1
            if obj_map.obj.id == -1
                junction.call id_j, get_id, store_funcs, store, obj_map.map, obj_map.obj, (id) ->
                    obj_map.obj.id = id

        junction.finalise id_j, () ->
            # Save all the objects now that they have id's
            #   
            save_j = junction.create()

            for obj_map in flat_object_list
                junction.call save_j, _save, store, store_funcs, obj_map.map, obj_map.obj, (obj) ->

            junction.finalise save_j, () ->
                callback obj        

    remove = (store,store_funcs,map,obj,callback) ->
        ''


    exports =
        get_id:get_id
        save:save
        save_all:save_all
        load:load
        remove:remove
