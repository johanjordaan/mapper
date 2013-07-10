// Generated by CoffeeScript 1.6.3
(function() {
  var define;

  if (typeof define === "undefined" || define === null) {
    define = require('amdefine')(module);
  }

  define(['chai', './test_maps', '../lib/basic_store'], function(chai, test_maps, basic_store) {
    var expect, should;
    should = chai.should();
    expect = chai.expect;
    describe('_get_id', function() {
      it('should get create a new id if it does not exist and increment it each time get_id is called', function(done) {
        var bank, store;
        store = {};
        bank = {};
        return basic_store._get_id(store, test_maps.bank_map, bank, function(id) {
          id.should.equal(1);
          expect(store[test_maps.bank_map.model_name]).to.exist;
          store[test_maps.bank_map.model_name].should.equal(1);
          return basic_store._get_id(store, test_maps.bank_map, {}, function(id) {
            id.should.equal(2);
            store[test_maps.bank_map.model_name].should.equal(2);
            return done();
          });
        });
      });
      return it('should return the objects id_field value if id_field is defined', function(done) {
        var store, user;
        store = {};
        user = {
          email: 'me@here.com'
        };
        return basic_store._get_id(store, test_maps.user_map, user, function(id) {
          id.should.equal(user.email);
          return done();
        });
      });
    });
    return describe('save', function() {
      it('should save the object in the store and assign an id if it does not have one', function(done) {
        var bank, store;
        store = {};
        bank = {
          name: 'Bank One'
        };
        return basic_store.save(store, test_maps.bank_map, bank, function(saved_bank) {
          saved_bank.id.should.equal(1);
          expect(store["" + test_maps.bank_map.model_name + ":" + saved_bank.id]).to.exist;
          saved_bank.name.should.equal(bank.name);
          return done();
        });
      });
      it('should should save multiple objects and add them to the default collection', function(done) {
        var bank_1, bank_2, store;
        store = {};
        bank_1 = {
          name: 'Bank One'
        };
        bank_2 = {
          name: 'Bank Two'
        };
        return basic_store.save(store, test_maps.bank_map, bank_1, function(saved_bank_1) {
          saved_bank_1.id.should.equal(1);
          return basic_store.save(store, test_maps.bank_map, bank_2, function(saved_bank_2) {
            saved_bank_2.id.should.equal(2);
            store[test_maps.bank_map.default_collection].length.should.equal(2);
            return done();
          });
        });
      });
      return it('should should save an object utilising all the features of the mapper', function(done) {
        var account_1, account_2, bank, person, store;
        store = {};
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
        return basic_store.save(store, test_maps.bank_map, bank, function(saved_bank) {
          return basic_store.save(store, test_maps.person_map, person, function(saved_person) {
            saved_person.id.should.equal(1);
            saved_person.accounts.length.should.equal(2);
            saved_person.accounts[0].id.should.equal(1);
            saved_person.accounts[0].bank.id.should.equal(1);
            saved_person.accounts[1].id.should.equal(2);
            saved_person.accounts[1].bank.id.should.equal(1);
            saved_person.lotto_numbers.length.should.equal(3);
            store[test_maps.person_map.default_collection].length.should.equal(1);
            store[test_maps.account_map.default_collection].length.should.equal(2);
            store[test_maps.bank_map.default_collection].length.should.equal(1);
            console.log(store);
            return done();
          });
        });
      });
    });
  });

}).call(this);
