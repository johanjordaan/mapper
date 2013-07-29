if !define?
	define = require('amdefine')(module) 

define ['chai','./test_maps','../lib/store','../lib/js_store'], (chai,test_maps,store,js_store) ->
	should = chai.should()
	expect = chai.expect

	stores =
		js_store :
			store : {}
			name : 'js_store'

	describe 'get_id', () ->
		it 'should get create a new id if it does not exist and increment it each time get_id is called', (done) ->
			local_store = {}
			bank = {}
			store.get_id local_store,js_store,test_maps.bank_map,bank,(id) ->
				id.should.equal 1	
				store.get_id local_store,js_store,test_maps.bank_map,bank,(id) ->
					id.should.equal 2	
					done()

		it 'should return the objects id_field value if id_field is defined', (done) ->
			local_store = {}
			user = {email:'me@here.com'}
			store.get_id local_store,js_store,test_maps.user_map,user,(id) ->
				id.should.equal user.email
				done()

	describe 'save', () ->
		it 'should save the object in the store and assign an id if it does not have one', (done) ->
			local_store = {}
			bank = {name:'Bank One'}
			store.save local_store,js_store,test_maps.bank_map,bank,(saved_bank) ->
				saved_bank.id.should.equal 1
				saved_bank.name.should.equal bank.name
				done()

		it 'should should save multiple objects and add them to the default collection', (done) ->
			local_store = {}
			bank_1 = {name:'Bank One'}
			bank_2 = {name:'Bank Two'}
			store.save local_store,js_store,test_maps.bank_map,bank_1,(saved_bank_1) ->
				saved_bank_1.id.should.equal 1
				store.save local_store,js_store,test_maps.bank_map,bank_2,(saved_bank_2) ->
					saved_bank_2.id.should.equal 2
					done()

		it 'should should save an object utilising all the features of the mapper', (done) ->
			local_store = {}
			bank = {name:'Bank One'}
			account_1 = {type:'saving',bank:bank}
			account_2 = {type:'loan',bank:bank}
			person = {name:'Johan',accounts:[account_1,account_2],lotto_numbers:[1,2,3]}

			store.save local_store,js_store,test_maps.bank_map,bank,(saved_bank) ->
				store.save local_store,js_store,test_maps.person_map,person,(saved_person) ->
					saved_person.id.should.equal 1
					saved_person.accounts.length.should.equal 2
					saved_person.accounts[0].id.should.equal 1
					saved_person.accounts[0].bank.id.should.equal 1
					saved_person.accounts[1].id.should.equal 2
					saved_person.accounts[1].bank.id.should.equal 1
					saved_person.lotto_numbers.length.should.equal 3
					done()


		it 'should should save a list of objects', (done) ->
			local_store = {}
			bank = {name:'Bank One'}
			account_1 = {type:'saving',bank:bank}
			account_2 = {type:'loan',bank:bank}

			store.save local_store,js_store,test_maps.bank_map,bank,(saved_bank) ->
				store.save_all local_store,js_store,test_maps.account_map,[account_1,account_2],(saved_accounts) ->
					saved_accounts.length.should.equal 2
					done()

	describe 'load', () ->
		it 'should load the object in the store', (done) ->
			local_store = {}
			bank = {name:'Bank One'}
			store.save local_store,js_store,test_maps.bank_map,bank,(saved_bank) ->
				saved_bank.id.should.equal 1
				store.load local_store,js_store,test_maps.bank_map,1,(loaded_bank) ->
					loaded_bank.id.should.equal 1
					loaded_bank.name.should.equal bank.name
					done()

		it 'should should load an object utilising all the features of the mapper', (done) ->
			local_store = {}
			bank = {name:'Bank One'}
			account_1 = {type:'saving',bank:bank}
			account_2 = {type:'loan',bank:bank}
			person = {name:'Johan',accounts:[account_1,account_2],lotto_numbers:[1,2,3]}

			store.save local_store,js_store,test_maps.bank_map,bank,(saved_bank) ->
				store.save local_store,js_store,test_maps.person_map,person,(saved_person) ->
					store.load local_store,js_store,test_maps.person_map,1,(loaded_person) ->
						loaded_person.id.should.equal 1
						loaded_person.accounts.length.should.equal 2
						loaded_person.accounts[0].id.should.equal 1
						loaded_person.accounts[0].bank.id.should.equal 1
						loaded_person.accounts[1].id.should.equal 2
						loaded_person.accounts[1].bank.id.should.equal 1,'Bank id should be 1'
						loaded_person.lotto_numbers.length.should.equal 3
						done()


