// Generated by CoffeeScript 1.6.3
(function() {
  var define,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  if (typeof define === "undefined" || define === null) {
    define = require('amdefine')(module);
  }

  define(['chai', './test_maps', '../lib/js_store'], function(chai, test_maps, js_store) {
    var expect, should;
    should = chai.should();
    expect = chai.expect;
    describe('get_id', function() {
      return it('it should get a new id from the store', function(done) {
        var store;
        store = {};
        return js_store.get_id(store, 'test', function(id) {
          id.should.equal = 1;
          store['test'].should.equal(1);
          return js_store.get_id(store, 'test', function(id) {
            id.should.equal = 2;
            store['test'].should.equal(2);
            return done();
          });
        });
      });
    });
    describe('save', function() {
      return it('should save an object to the store', function(done) {
        var person, store;
        store = {};
        person = {
          id: 2,
          name: 'johan'
        };
        return js_store.save(store, 'Person', person, function(saved_person) {
          expect(store['Person:2']).to.exist;
          saved_person.name.should.equal('johan');
          saved_person.id.should.equal(2);
          return done();
        });
      });
    });
    describe('save_refs', function() {
      return it('should save an objects refs to the store', function(done) {
        var person, ref_list, store;
        store = {};
        person = {
          id: 2,
          name: 'johan'
        };
        ref_list = {
          accounts: [1, 2],
          contact_details: [6, 5]
        };
        return js_store.save_refs(store, 'Person', person, ref_list, function() {
          expect(store['Person:2:accounts']).to.exist;
          store['Person:2:accounts'].length.should.equal(2);
          store['Person:2:accounts'][0].should.equal(1);
          store['Person:2:accounts'][1].should.equal(2);
          expect(store['Person:2:contact_details']).to.exist;
          store['Person:2:contact_details'].length.should.equal(2);
          store['Person:2:contact_details'][0].should.equal(6);
          store['Person:2:contact_details'][1].should.equal(5);
          return done();
        });
      });
    });
    describe('add_to_collection', function() {
      return it('should add an object to a collection in the store', function(done) {
        var johan, lorraine, store;
        store = {};
        johan = {
          id: 2,
          name: 'johan'
        };
        lorraine = {
          id: 5,
          name: 'lorraine'
        };
        return js_store.add_to_collection(store, 'People', lorraine, function() {
          expect(store['People']).to.exist;
          store['People'].length.should.equal(1);
          store['People'][0].should.equal(5);
          return js_store.add_to_collection(store, 'People', johan, function() {
            store['People'].length.should.equal(2);
            store['People'][1].should.equal(2);
            return done();
          });
        });
      });
    });
    describe('load_collection', function() {
      return it('should load a collections ids', function(done) {
        var johan, lorraine, store;
        store = {};
        johan = {
          id: 2,
          name: 'johan'
        };
        lorraine = {
          id: 5,
          name: 'lorraine'
        };
        return js_store.add_to_collection(store, 'People', lorraine, function() {
          expect(store['People']).to.exist;
          store['People'].length.should.equal(1);
          store['People'][0].should.equal(5);
          return js_store.add_to_collection(store, 'People', johan, function() {
            store['People'].length.should.equal(2);
            store['People'][1].should.equal(2);
            return js_store.load_collection(store, 'People', function(ids) {
              ids.length.should.equal(2);
              (__indexOf.call(ids, 2) >= 0).should.equal(true);
              (__indexOf.call(ids, 5) >= 0).should.equal(true);
              return done();
            });
          });
        });
      });
    });
    describe('load', function() {
      return it('should load an object from the store', function(done) {
        var person, store;
        store = {};
        person = {
          id: 2,
          name: 'johan'
        };
        return js_store.save(store, 'Person', person, function(saved_person) {
          expect(store['Person:2']).to.exist;
          return js_store.load(store, 'Person', 2, function(loaded_person) {
            expect(loaded_person).to.exist;
            loaded_person.id.should.equal(2);
            loaded_person.name.should.equal('johan');
            return done();
          });
        });
      });
    });
    return describe('load_refs', function() {
      return it('should an objects refs to the store', function(done) {
        var person, ref_list, store;
        store = {};
        person = {
          id: 2,
          name: 'johan'
        };
        ref_list = {
          accounts: [1, 2],
          contact_details: [6, 5]
        };
        return js_store.save_refs(store, 'Person', person, ref_list, function() {
          return js_store.load_refs(store, 'Person', 2, ['accounts', 'contact_details'], function(loaded_ref_list) {
            expect(loaded_ref_list).to.exist;
            expect(loaded_ref_list['accounts']).to.exist;
            loaded_ref_list['accounts'].length.should.equal(2);
            loaded_ref_list['accounts'][0].should.equal(1);
            loaded_ref_list['accounts'][1].should.equal(2);
            expect(loaded_ref_list['contact_details']).to.exist;
            loaded_ref_list['contact_details'].length.should.equal(2);
            loaded_ref_list['contact_details'][0].should.equal(6);
            loaded_ref_list['contact_details'][1].should.equal(5);
            return done();
          });
        });
      });
    });
  });

}).call(this);
