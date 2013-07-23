if !define?
    define = require('amdefine')(module) 

define ['redis','../lib/junction'], (redis,junction) ->

    exports = 
        get_id : (store,name,callback) ->
            store.client.incr name,(err,id) ->
                callback id

        save : (store,name,obj,callback) ->
            key = "#{name}:#{obj.id}"
            store.client.hmset key,obj,(err,reply) ->
                callback()
        
        save_refs : (store,name,obj,ref_list,callback) ->
            multi = store.client.multi()

            for ref_name,refs of ref_list
                key = "#{name}:#{obj.id}:#{ref_name}"
                for ref_id in refs
                    multi.sadd key,ref_id

            multi.exec (err,reply) ->
                callback()

        load_collection : (store,name,callback) ->
            store.client.smembers name,(err,ids) ->
                ret_val = []
                ret_val.push(Number(id)) for id in ids    
                callback ret_val       

        add_to_collection : (store,name,obj,callback) ->
            store.client.sadd name,obj.id,(err,reply) ->
                callback()

        load : (store,name,id,callback) ->
            key = "#{name}:#{id}"
            store.client.hgetall key,(err,obj) ->
                obj.id = id
                callback obj

        load_refs : (store,name,id,field_names,callback) ->
            ret_val = {}
            multi = store.client.multi()

            for field_name in field_names 
                key = "#{name}:#{id}:#{field_name}"
                multi.smembers key
            
            multi.exec (err,reply) ->        
                for field_name,idx in field_names
                    ret_val[field_name] = reply[idx]
                callback ret_val       
