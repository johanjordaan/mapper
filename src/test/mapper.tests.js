var assert = require('assert');
var should = require('chai').should();
var expect = require('chai').expect;


var redis = require('redis');

var printf = require('../utils/printf.js').printf
var mapper = require('../utils/mapper.js');
var Mapper = require('../utils/mapper.js').Mapper;


// Test maps
//
// Field : type - List for list of objects
//                Simple for simple fields - Default (Should later be things like int/string etc to type check)
//                Ref for ref to another object
//         default_value - value to to be created with if not specified in constructor
//         map_name - name of map to use for list and ref types  
//         internal - for list and refs it specifies wheter new objects are created or not
//
// NOTE : To ref a map it must be defined before reffing. This also forces you to think about recoursive definitions

// Need to build in a chack that id_field is a valid field

var user_map = {
	model_name 	: 'User',
	id_field	: 'email',
	fields 	: {
		email	: { type:'Simple', default_value:'*email*' },
		name 	: { type:'Simple', default_value:'*name*' },
		password: { type:'Simple', default_value:'*password*' }
	},
	default_collection : 'Users'
}

var Bank = function(map,source) {
	this._name = 'Bank';
}

var bank_map = {
	model_name	: 'Bank',		
	fields 	: {
		name 	 : { type:'Simple', default_value:'*name*' }
	},
	default_collection : 'Banks',
	cls:Bank
}

var contact_details_map = {
	model_name	: 'ContactDetails',		
	fields 	: {
		cel_no 	 : { type:'Simple', default_value:'*cel_no*' },
		tel_no 	 : { type:'Simple', default_value:'*tel_no*' },
		email 	 : { type:'Simple', default_value:'*email*' }
	},
}

var bank_map_with_init = {
	model_name	: 'Bank',
	fields 	: {
		name 	 : { type:'Simple', default_value:'*name*' }
	},
	call_after_load : [],
	default_collection : 'Banks'
}

var Account = function(map,source) {
	this._name = 'Account';
}

var account_map = {
	model_name	: 'Account',	
	fields	: {
		type 	: { type:'Simple', default_value:'*type*' },
		bank	: { type:'Ref', map:bank_map, internal:false }
	},
	default_collection : 'Accounts',
	cls:Account,
};

var Person = function(map,source) {
	this._name = 'Person';
}


var person_map = {
    model_name 	: 'Person',
    fields 	: {
		name 	 				: { type:'Simple', default_value:'*name*' },
		surname	 				: { type:'Simple', default_value:'*surname*' },
		age		 				: { type:'Simple', default_value:10,conversion:Number },
		contact_details			: { type:'Ref', map:contact_details_map, internal:true },
		extra_contact_details	: { type:'Ref', map:contact_details_map, internal:true },
		accounts 				: { type:'List', map : account_map, internal : true },
		lotto_numbers			: { type:'SimpleList', default_value:[], conversion:Number },
	},
	default_collection : 'People',
	cls:Person
};



var debug_db = 15;

describe('Mapper', function() {
    describe('#constructor', function() {
        it('should create a mapper that uses the specified db', function() {
			var mapper = new Mapper(1);
			mapper.db_id.should.equal(1);
			var mapper = new Mapper(15);
			mapper.db_id.should.equal(15);
        });
    });
	describe('#create',function() {
		it('should create an instance of the class based the map fields and defaults', function() {
			var mapper = new Mapper();
			var p = mapper.create(person_map);
			p.id.should.equal(-1);
			p.name.should.equal(person_map.fields.name.default_value);
			p.surname.should.equal(person_map.fields.surname.default_value);
			p.contact_details.should.be.a('object');
			p.contact_details.cel_no.should.equal(contact_details_map.fields.cel_no.default_value);
			p.contact_details.tel_no.should.equal(contact_details_map.fields.tel_no.default_value);
			p.contact_details.email.should.equal(contact_details_map.fields.email.default_value);
			p.accounts.should.be.a('Array');
			p.accounts.should.have.length(0);
		});
		it('should create an instance of the class based the map fields and defaults and the initial values', function() {
			var mapper = new Mapper();
			var initial_values = {surname:'jordaan'}				;
			var p = mapper.create(person_map,initial_values);
			p.id.should.equal(-1);
			p.name.should.equal(person_map.fields.name.default_value);
			p.surname.should.equal(initial_values.surname);
			p.accounts.should.be.a('Array');
			p.accounts.should.have.length(0);
		});
	});
	describe("#update",function(){
		it('should extend the desination object based on the map and initial', function() {
			var mapper = new Mapper();
			var initial_values = {surname:'jordaan',age:'32',accounts:[{type:'Savings',bank:{name:"Standard Bank"}}]};	
			var local_p = {};	
			
			mapper.update(person_map,local_p,initial_values);
			
			local_p.surname.should.equal(initial_values.surname);
			local_p.age.should.equal(32);
			local_p.accounts.should.be.a('Array');
			local_p.accounts.should.have.length(1);
		});
	});
	describe('#_all',function() {
		it('should list the unsaved objects in the tree',function() {
			var mapper = new Mapper(debug_db);
			var p = mapper.create(person_map);
			var us = mapper._all(person_map,p);
			us.length.should.equal(3);
			var b = mapper.create(bank_map);
			var a = mapper.create(account_map,{bank:b});
			p.accounts.push(a);
			var us = mapper._all(person_map,p);
			us.length.should.equal(5);
		});
	});
	describe('#save/#load',function() {
		beforeEach(function(done) { 
			var client = redis.createClient();
			client.select(debug_db);
			client.FLUSHDB(function() { 
				client.quit();
				done(); 
			});
		});
		it('xxx',function(done) {
			var mapper = new Mapper(debug_db);
			var p = mapper.create(person_map);
			var b = mapper.create(bank_map);
			var a = mapper.create(account_map,{bank:b});
			p.accounts.push(a);
			p.name = 'Johan';
			mapper.save(person_map,p,function(saved_person) { 
				saved_person.name.should.equal('Johan');
				mapper.load(person_map,1,function(loaded_person){
					loaded_person.name.should.equal('Johan');
					done();
				});
			});
		});
		it('should save/load a simple object (no list or refs fields)',function(done) {
			var mapper = new Mapper(debug_db);
			var initial_data = {name:'The Best Bank'};
			var b = mapper.create(bank_map,initial_data);
			mapper.save(bank_map,b,function(saved_bank){
				saved_bank.id.should.equal(1);
				mapper.load(bank_map,1,function(loaded_bank){
					loaded_bank.id.should.equal(1);
					loaded_bank.name.should.equal(initial_data.name);
					done();
				});
			})
		});

		it('should save/load a list of objects ',function(done) {
			var mapper = new Mapper(debug_db);
			var initial_data_1 = {name:'The Best Bank'};
			var initial_data_2 = {name:'The Worst Bank'};
			var b1 = mapper.create(bank_map,initial_data_1);
			var b2 = mapper.create(bank_map,initial_data_2);
			
			mapper.save_all(bank_map,[b1,b2],function(saved_banks) {
				saved_banks.length.should.equal(2);
				saved_banks[0].id.should.equal(1);
				saved_banks[1].id.should.equal(2);
				mapper.load_all(bank_map,function(loaded_banks){
					loaded_banks.length.should.equal(2);
					done();
				})
			});
		});
		
		it('should save a ref to any new objects to the collection specified in the map',function(done) {
			var mapper = new Mapper(debug_db);
			var initial_data_1 = {name:'The Best Bank'};
			var initial_data_2 = {name:'The Worst Bank'};
			var b1 = mapper.create(bank_map,initial_data_1);
			var b2 = mapper.create(bank_map,initial_data_2);

			mapper.save_all(bank_map,[b1,b2],function(saved_banks){
				saved_banks.length.should.equal(2);
				mapper.load_all(bank_map,function(loaded_banks){
					loaded_banks.length.should.equal(2);
					done();
				});
			});
		});

		it('should save/load a object with a ref (external) field',function(done) {
			var mapper = new Mapper(debug_db);
			var bank_initial_data = {name:'The Best Bank'};
			var account_initial_data = {type:'Savings Account'};
						
			var b = mapper.create(bank_map,bank_initial_data);
			var a = mapper.create(account_map,account_initial_data);

			mapper.save(bank_map,b,function(saved_bank){
				b.id.should.equal(1);
				a.bank = b;
				mapper.save(account_map,a,function(saved_account) {
					mapper.load(account_map,1,function(loaded_account){
						loaded_account.id.should.equal(1);
						loaded_account.type.should.equal(account_initial_data.type);
						loaded_account.bank.id.should.equal(1);
						loaded_account.bank.name.should.equal(bank_initial_data.name);
						done();
					});
				});
			})
		});
		it('should save/load a object with a list field',function(done) {
			var mapper = new Mapper(debug_db);
			var bank_initial_data = {name:'The Best Bank'};
			var sa_account_initial_data = {type:'Savings Account'};
			var cc_account_initial_data = {type:'Credit Card'};
			var person_initial_data = {name:'johan',surname:'jordaan'};			
						
			var b = mapper.create(bank_map,bank_initial_data);
			var sa = mapper.create(account_map,sa_account_initial_data);
			var cc = mapper.create(account_map,cc_account_initial_data);
			var p = mapper.create(person_map,person_initial_data);
			
			mapper.save(bank_map,b,function(saved_bank){
				b.id.should.equal(1);
				sa.bank = b;
				cc.bank = b;
				p.accounts.push(sa);
				p.accounts.push(cc);
				mapper.save(person_map,p,function() {
					mapper.load(person_map,1,function(loaded_person){
						loaded_person.id.should.equal(1);
						loaded_person.name.should.equal(person_initial_data.name);
						loaded_person.surname.should.equal(person_initial_data.surname);
						loaded_person.accounts.should.have.length(2);
						// Misiing some checks ?
						done();
					});
				});
			})
		});

		it('should load an object and call the constructor if constructor args are specified',function(done) {
			var mapper = new Mapper(debug_db);
			var bank_initial_data = {name:'The Best Bank'};
			var b = mapper.create(bank_map_with_init,bank_initial_data);
			
			var init = function(obj) {
				obj.derived_name = obj.name;
			}
			bank_map_with_init.call_after_load = [init];
			
			mapper.save(bank_map,b,function(saved_bank){
				b.id.should.equal(1);
				b.name.should.equal(bank_initial_data.name);
				mapper.load(bank_map_with_init,1,function(loaded_bank){
					loaded_bank.id.should.equal(1);
					loaded_bank.name.should.equal(bank_initial_data.name);
					loaded_bank.derived_name.should.equal(bank_initial_data.name);
					done();
				});
			})
		});

		it('should save all internal ref fields as their own objects',function(done) {
			var mapper = new Mapper(debug_db);
			var p = mapper.create(person_map);
			mapper.save(person_map,p,function(saved_person) {
				p.contact_details.id.should.not.equal(p.extra_contact_details.id);
				mapper.load(person_map,1,function(loaded_person){
					loaded_person.contact_details.id.should.not.equal(loaded_person.extra_contact_details.id);
					loaded_person.contact_details.email.should.equal(contact_details_map.fields.email.default_value);
					done();
				});
			})
		});
		
		it('should throw an exception if id or map is not provided',function() {
			var mapper = new Mapper(debug_db);
			var fn = function() { mapper.load(); }
			expect(fn).to.throw("Map not provided for load.");
			var fn2 = function() { mapper.load(person_map); }
			expect(fn2).to.throw("ID not provided for load.");
		});

		it('should use the conversion function when specified on loading',function(done) {
			var mapper = new Mapper(debug_db);
			var p = mapper.create(person_map);
			p.age = 22;
			mapper.save(person_map,p,function(saved_person) {
				p.contact_details.id.should.not.equal(p.extra_contact_details.id);
				mapper.load(person_map,1,function(loaded_person){
					loaded_person.contact_details.id.should.not.equal(loaded_person.extra_contact_details.id);
					loaded_person.contact_details.email.should.equal(contact_details_map.fields.email.default_value);
					loaded_person.age.should.be.equal(22);
					done();
				});
			});
		});
		
		it('should use the provided field as the id insetad of the default id',function(done) {
			var mapper = new Mapper(debug_db);
			var initial_data = {email:'djjordaan@gmail.com',name:'Johan',password:'123'};
			var u = mapper.create(user_map,initial_data);
			mapper.save(user_map,u,function(saved_user){
				saved_user.id.should.equal(initial_data.email);
				mapper.load(user_map,initial_data.email,function(loaded_user){
					loaded_user.id.should.equal(initial_data.email);
					loaded_user.name.should.equal(initial_data.name);
					loaded_user.password.should.equal(initial_data.password);
					done();
				});
			});
		});
		
		it('should save and load SimpleList types by de-/serialising them and loading/saving them',function(done){
			var mapper = new Mapper(debug_db);
			var initial_data = {};
			var p = mapper.create(person_map,initial_data);

			p.lotto_numbers.should.be.a('Array');
			
			p.lotto_numbers.push(12);
			p.lotto_numbers.push(18);
			p.name = 'Johan';
			
			mapper.save(person_map,p,function(saved_person){
				saved_person.id.should.equal(1);
				mapper.load(person_map,1,function(loaded_person){
					loaded_person.id.should.equal(1);
					loaded_person.lotto_numbers.length.should.equal(2);
					done();
				});
			});
		});
		
		
		it('should create a class of the specific type when loading a map with a cls attr',function(done){
			var mapper = new Mapper(debug_db);
			var p = mapper.create(person_map,{});
			var b = mapper.create(bank_map);
			var a = mapper.create(account_map,{bank:b});
			p.accounts.push(a);	
			p.lotto_numbers.push(12);
			p.lotto_numbers.push(18);


			p.name = 'Johan';
			p.accounts.length.should.equal(1);
			p.lotto_numbers.length.should.equal(2);

			mapper.save(person_map,p,function(saved_person){
				saved_person.id.should.equal(1);
				mapper.load(person_map,1,function(loaded_person){
					loaded_person.id.should.equal(1);
					loaded_person._name.should.equal('Person');
					loaded_person.accounts.length.should.equal(1);
					loaded_person.accounts[0]._name.should.equal('Account');
					loaded_person.accounts[0].bank._name.should.equal('Bank');
					loaded_person.lotto_numbers.length.should.equal(2);
					done();
				});
			});
		});

	});
})
