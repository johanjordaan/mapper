// Generated by CoffeeScript 1.6.3
(function() {
  var define;

  if (typeof define === "undefined" || define === null) {
    define = require('amdefine')(module);
  }

  define([], function() {
    var exports;
    return exports = {
      get_id: function(store, name, callback) {
        if (store[name] == null) {
          store[name] = 0;
        }
        store[name]++;
        return callback(store[name]);
      },
      save: function(store, name, obj, callback) {
        var key;
        key = "" + name + ":" + obj.id;
        store[key] = obj;
        return callback(obj);
      },
      save_refs: function(store, name, obj, ref_list, callback) {
        var key, ref_id, ref_name, refs, _i, _len;
        for (ref_name in ref_list) {
          refs = ref_list[ref_name];
          key = "" + name + ":" + obj.id + ":" + ref_name;
          store[key] = [];
          for (_i = 0, _len = refs.length; _i < _len; _i++) {
            ref_id = refs[_i];
            store[key].push(ref_id);
          }
        }
        return callback();
      },
      load_collection: function(store, name, callback) {
        return callback(store[name]);
      },
      add_to_collection: function(store, name, obj, callback) {
        if (store[name] == null) {
          store[name] = [];
        }
        store[name].push(obj.id);
        return callback();
      },
      load: function(store, name, id, callback) {
        var key;
        key = "" + name + ":" + id;
        return callback(store[key]);
      },
      load_refs: function(store, name, id, field_names, callback) {
        var field_name, key, ret_val, _i, _len;
        ret_val = {};
        for (_i = 0, _len = field_names.length; _i < _len; _i++) {
          field_name = field_names[_i];
          key = "" + name + ":" + id + ":" + field_name;
          ret_val[field_name] = store[key];
        }
        return callback(ret_val);
      },
      remove: function(store, name, obj, callback) {
        var key;
        key = "" + name + ":" + obj.id;
        delete store[key];
        return callback();
      },
      remove_refs: function(store, name, obj, ref_list, callback) {
        var key, ref_name, refs;
        for (ref_name in ref_list) {
          refs = ref_list[ref_name];
          key = "" + name + ":" + obj.id + ":" + ref_name;
          delete store[key];
        }
        return callback();
      }
    };
  });

}).call(this);
