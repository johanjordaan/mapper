if !define?
	define = require('amdefine')(module) 

define ['chai','./test_maps','../lib/basic_store'], (chai,test_maps,basic_store) ->
	should = chai.should()
	expect = chai.expect

	describe '_get_id', () ->
		it 'should get create a new id if it does not exist and increment it each time get_id is called', (done) ->
			store = {}
			bank = {}
			basic_store._get_id store,test_maps.bank_map,bank,(id) ->
				id.should.equal 1	
				expect(store[test_maps.bank_map.model_name]).to.exist
				store[test_maps.bank_map.model_name].should.equal 1

				basic_store._get_id store,test_maps.bank_map,{},(id) ->
					id.should.equal 2	
					store[test_maps.bank_map.model_name].should.equal 2
					done()

		it 'should return the objects id_field value if id_field is defined', (done) ->
			store = {}
			user = {email:'me@here.com'}
			basic_store._get_id store,test_maps.user_map,user,(id) ->
				id.should.equal user.email
				done()

	describe 'save', () ->
		it 'should save the object in the store and assign an id if it does not have one', (done) ->
			store = {}
			bank = {name:'Bank One'}
			basic_store.save store,test_maps.bank_map,bank,(saved_bank) ->
				saved_bank.id.should.equal 1
				expect(store["#{test_maps.bank_map.model_name}:#{saved_bank.id}"]).to.exist
				saved_bank.name.should.equal bank.name
				done()

		it 'should should save multiple objects and add them to the default collection', (done) ->
			store = {}
			bank_1 = {name:'Bank One'}
			bank_2 = {name:'Bank Two'}
			basic_store.save store,test_maps.bank_map,bank_1,(saved_bank_1) ->
				saved_bank_1.id.should.equal 1
				basic_store.save store,test_maps.bank_map,bank_2,(saved_bank_2) ->
					saved_bank_2.id.should.equal 2

					store[test_maps.bank_map.default_collection].length.should.equal 2	

					done()

		it 'should should save an object utilising all the features of the mapper', (done) ->
			store = {}
			bank = {name:'Bank One'}
			account_1 = {type:'saving',bank:bank}
			account_2 = {type:'loan',bank:bank}
			person = {name:'Johan',accounts:[account_1,account_2],lotto_numbers:[1,2,3]}

			basic_store.save store,test_maps.bank_map,bank,(saved_bank) ->
				basic_store.save store,test_maps.person_map,person,(saved_person) ->
					saved_person.id.should.equal 1
					saved_person.accounts.length.should.equal 2
					saved_person.accounts[0].id.should.equal 1
					saved_person.accounts[0].bank.id.should.equal 1
					saved_person.accounts[1].id.should.equal 2
					saved_person.accounts[1].bank.id.should.equal 1
					saved_person.lotto_numbers.length.should.equal 3

					store[test_maps.person_map.default_collection].length.should.equal 1
					store[test_maps.account_map.default_collection].length.should.equal 2
					store[test_maps.bank_map.default_collection].length.should.equal 1

					done()

		it 'should should save a list of objects', (done) ->
			store = {}
			bank = {name:'Bank One'}
			account_1 = {type:'saving',bank:bank}
			account_2 = {type:'loan',bank:bank}

			basic_store.save store,test_maps.bank_map,bank,(saved_bank) ->
				basic_store.save_all store,[{map:test_maps.account_map,obj:account_1},{map:test_maps.account_map,obj:account_2}],(saved_accounts) ->
					saved_accounts.length.should.equal 2
					done()

	describe 'load', () ->
		it 'should load the object in the store', (done) ->
			store = {}
			bank = {name:'Bank One'}
			basic_store.save store,test_maps.bank_map,bank,(saved_bank) ->
				saved_bank.id.should.equal 1
				basic_store.load store,test_maps.bank_map,1,(loaded_bank) ->
					loaded_bank.id.should.equal 1
					loaded_bank.name.should.equal bank.name
					done()

		it 'should should load an object utilising all the features of the mapper', (done) ->
			store = {}
			bank = {name:'Bank One'}
			account_1 = {type:'saving',bank:bank}
			account_2 = {type:'loan',bank:bank}
			person = {name:'Johan',accounts:[account_1,account_2],lotto_numbers:[1,2,3]}

			basic_store.save store,test_maps.bank_map,bank,(saved_bank) ->
				basic_store.save store,test_maps.person_map,person,(saved_person) ->
					basic_store.load store,test_maps.person_map,person,(loaded_person) ->
						loaded_person.id.should.equal 1
						loaded_person.accounts.length.should.equal 2
						loaded_person.accounts[0].id.should.equal 1
						loaded_person.accounts[0].bank.id.should.equal 1
						loaded_person.accounts[1].id.should.equal 2
						loaded_person.accounts[1].bank.id.should.equal 1
						loaded_person.lotto_numbers.length.should.equal 3

						done()


