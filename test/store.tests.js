// Generated by CoffeeScript 1.6.3
(function() {
  var define;

  if (typeof define === "undefined" || define === null) {
    define = require('amdefine')(module);
  }

  define(['chai', './test_maps', '../lib/store', '../lib/js_store'], function(chai, test_maps, store, js_store) {
    var expect, should, stores;
    should = chai.should();
    expect = chai.expect;
    stores = {
      js_store: {
        store: {},
        name: 'js_store'
      }
    };
    describe('get_id', function() {
      it('should get create a new id if it does not exist and increment it each time get_id is called', function(done) {
        var bank, local_store;
        local_store = {};
        bank = {};
        return store.get_id(local_store, js_store, test_maps.bank_map, bank, function(id) {
          id.should.equal(1);
          return store.get_id(local_store, js_store, test_maps.bank_map, bank, function(id) {
            id.should.equal(2);
            return done();
          });
        });
      });
      return it('should return the objects id_field value if id_field is defined', function(done) {
        var local_store, user;
        local_store = {};
        user = {
          email: 'me@here.com'
        };
        return store.get_id(local_store, js_store, test_maps.user_map, user, function(id) {
          id.should.equal(user.email);
          return done();
        });
      });
    });
    describe('save', function() {
      it('should save the object in the store and assign an id if it does not have one', function(done) {
        var bank, local_store;
        local_store = {};
        bank = {
          name: 'Bank One'
        };
        return store.save(local_store, js_store, test_maps.bank_map, bank, function(saved_bank) {
          saved_bank.id.should.equal(1);
          saved_bank.name.should.equal(bank.name);
          return done();
        });
      });
      it('should should save multiple objects and add them to the default collection', function(done) {
        var bank_1, bank_2, local_store;
        local_store = {};
        bank_1 = {
          name: 'Bank One'
        };
        bank_2 = {
          name: 'Bank Two'
        };
        return store.save(local_store, js_store, test_maps.bank_map, bank_1, function(saved_bank_1) {
          saved_bank_1.id.should.equal(1);
          return store.save(local_store, js_store, test_maps.bank_map, bank_2, function(saved_bank_2) {
            saved_bank_2.id.should.equal(2);
            return done();
          });
        });
      });
      it('should should save an object utilising all the features of the mapper', function(done) {
        var account_1, account_2, bank, local_store, person;
        local_store = {};
        bank = {
          name: 'Bank One'
        };
        account_1 = {
          type: 'saving',
          bank: bank
        };
        account_2 = {
          type: 'loan',
          bank: bank
        };
        person = {
          name: 'Johan',
          accounts: [account_1, account_2],
          lotto_numbers: [1, 2, 3]
        };
        return store.save(local_store, js_store, test_maps.bank_map, bank, function(saved_bank) {
          return store.save(local_store, js_store, test_maps.person_map, person, function(saved_person) {
            saved_person.id.should.equal(1);
            saved_person.accounts.length.should.equal(2);
            saved_person.accounts[0].id.should.equal(1);
            saved_person.accounts[0].bank.id.should.equal(1);
            saved_person.accounts[1].id.should.equal(2);
            saved_person.accounts[1].bank.id.should.equal(1);
            saved_person.lotto_numbers.length.should.equal(3);
            return done();
          });
        });
      });
      return it('should should save a list of objects', function(done) {
        var account_1, account_2, bank, local_store;
        local_store = {};
        bank = {
          name: 'Bank One'
        };
        account_1 = {
          type: 'saving',
          bank: bank
        };
        account_2 = {
          type: 'loan',
          bank: bank
        };
        return store.save(local_store, js_store, test_maps.bank_map, bank, function(saved_bank) {
          return store.save_all(local_store, js_store, test_maps.account_map, [account_1, account_2], function(saved_accounts) {
            saved_accounts.length.should.equal(2);
            return done();
          });
        });
      });
    });
    describe('load', function() {
      it('should load the object in the store', function(done) {
        var bank, local_store;
        local_store = {};
        bank = {
          name: 'Bank One'
        };
        return store.save(local_store, js_store, test_maps.bank_map, bank, function(saved_bank) {
          saved_bank.id.should.equal(1);
          return store.load(local_store, js_store, test_maps.bank_map, 1, function(loaded_bank) {
            loaded_bank.id.should.equal(1);
            loaded_bank.name.should.equal(bank.name);
            return done();
          });
        });
      });
      return it('should should load an object utilising all the features of the mapper', function(done) {
        var account_1, account_2, bank, local_store, person;
        local_store = {};
        bank = {
          name: 'Bank One'
        };
        account_1 = {
          type: 'saving',
          bank: bank
        };
        account_2 = {
          type: 'loan',
          bank: bank
        };
        person = {
          name: 'Johan',
          accounts: [account_1, account_2],
          lotto_numbers: [1, 2, 3]
        };
        return store.save(local_store, js_store, test_maps.bank_map, bank, function(saved_bank) {
          return store.save(local_store, js_store, test_maps.person_map, person, function(saved_person) {
            return store.load(local_store, js_store, test_maps.person_map, 1, function(loaded_person) {
              loaded_person.id.should.equal(1);
              loaded_person.accounts.length.should.equal(2);
              loaded_person.accounts[0].id.should.equal(1);
              loaded_person.accounts[0].bank.id.should.equal(1);
              loaded_person.accounts[1].id.should.equal(2);
              loaded_person.accounts[1].bank.id.should.equal(1, 'Bank id should be 1');
              loaded_person.lotto_numbers.length.should.equal(3);
              return done();
            });
          });
        });
      });
    });
    return describe('load_all', function() {
      return it('should load all the objects in the default collection of a map', function(done) {
        var account_1, account_2, bank, local_store;
        local_store = {};
        bank = {
          name: 'Bank One'
        };
        account_1 = {
          type: 'saving',
          bank: bank
        };
        account_2 = {
          type: 'loan',
          bank: bank
        };
        return store.save(local_store, js_store, test_maps.bank_map, bank, function(saved_bank) {
          return store.save_all(local_store, js_store, test_maps.account_map, [account_1, account_2], function(saved_accounts) {
            saved_accounts.length.should.equal(2);
            return store.load_all(local_store, js_store, test_maps.account_map, function(loaded_accounts) {
              loaded_accounts.length.should.equal(2);
              return done();
            });
          });
        });
      });
    });
  });

}).call(this);
