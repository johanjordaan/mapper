if !define?
	define = require('amdefine')(module) 


define ['chai','../lib/mapper','./test_maps'], (chai,mapper,test_maps) ->
	should = chai.should();

	describe 'update', () ->
		it 'should ', () ->
			obj = mapper.update test_maps.user_map
			obj.id.should.equal = -1

		it 'should ', () ->
			obj = mapper.update test_maps.user_map,{}
			obj.id.should.equal = -1

		it 'should ', () ->
			obj = mapper.update test_maps.user_map,{},{email:'me@here.com'}
			obj.id.should.equal = -1
			obj.email.should.equal 'me@here.com'

	describe 'create', () ->
		it 'should ', () ->
			obj = mapper.create test_maps.user_map
			obj.id.should.equal = -1

	describe 'load', () ->
		it 'should ', () ->
			loader = (map,id) ->
				{id:id}

			obj = mapper.load test_maps.user_map,1,loader
			obj.id.should.equal = 1

			



 
