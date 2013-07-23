if !define?
    define = require('amdefine')(module) 


# This is a basic dictionary store
# 

define [], () ->

    exports = 
        get_id : (store,name,callback) ->
            if !store[name]?
                store[name] = 0   
            store[name]++     
            callback store[name]

        save : (store,name,obj,callback) ->
            key = "#{name}:#{obj.id}"
            store[key] = obj
            callback obj
        
        save_refs : (store,name,obj,ref_list,callback) ->
            for ref_name,refs of ref_list
                key = "#{name}:#{obj.id}:#{ref_name}"
                store[key] = []
                for ref_id in refs
                    store[key].push ref_id
            callback()        

        load_collection : (store,name,callback) ->
            callback store[name]        

        add_to_collection : (store,name,obj,callback) ->
            if !store[name]?
                store[name] = []
            store[name].push obj.id
            callback()

        load : (store,name,id,callback) ->
            key = "#{name}:#{id}"
            callback store[key]

        load_refs : (store,name,id,field_names,callback) ->
            ret_val = {}
            for field_name in field_names 
                key = "#{name}:#{id}:#{field_name}"
                ret_val[field_name] = store[key]
            callback ret_val       
