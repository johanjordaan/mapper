if !define?
	define = require('amdefine')(module) 

define ['chai','../lib/junction'], (chai,junction) ->
	should = chai.should();
	expect = chai.expect;

	describe 'create', () ->
		it 'should create a new clean junction context', () ->
			j = junction.create()
			j.count.should.equal 0
			j.results.length.should.equal 0


	describe 'call',() ->
		it 'should call the the function (without a callback) and save the results in the context', (done) ->
			j = junction.create()

			add = (a,b) ->
				j.count.should.equal 1
				a+b
			
			junction.call j,add,3,5

			junction.finalise j,(results) ->
				j.count.should.equal 0
				j.results.length.should.equal 1
				results.length.should.equal 1
				results[0].should.equal 8
				done()

		it 'should call the the function (with a callback) and save the results in the context', (done) ->
			j = junction.create()

			add = (a,b,cb) ->
				j.count.should.equal 1
				cb a+b
			
			junction.call j,add,3,5,(sum) ->
				sum.should.equal 8
				j.count.should.equal 1

			junction.finalise j,(results) ->
				j.count.should.equal 0
				j.results.length.should.equal 1
				results.length.should.equal 1
				results[0].should.equal 8
				done()




