if !define?
    define = require('amdefine')(module) 

define ['redis','chai','./test_maps','../lib/redis_store'], (redis,chai,test_maps,redis_store) ->
    should = chai.should()
    expect = chai.expect

    debug_db = 15

    clear_db = (done) ->
        client = redis.createClient()
        client.select debug_db
        client.FLUSHDB () -> 
            client.quit()
            done() 


    describe 'get_id', () ->
        beforeEach (done) -> clear_db(done)
        it 'it should get a new id from the store', (done) ->
            store = {client:redis.createClient()}
            store.client.select debug_db
            redis_store.get_id store,'test',(id) -> 
                id.should.equal = 1
                redis_store.get_id store,'test',(id) -> 
                    id.should.equal = 2
                    done()

    describe 'save', () ->
        beforeEach (done) -> clear_db(done)
        it 'should save an object to the store', (done) ->
            store = {client:redis.createClient()}
            store.client.select debug_db
            person = {id:2,name:'johan'}
            redis_store.save store,'Person',person,() ->               
                done()

    describe 'save_refs', () ->
        beforeEach (done) -> clear_db(done)
        it 'should save an objects refs to the store', (done) ->
            store = {client:redis.createClient()}
            store.client.select debug_db
            person = {id:2,name:'johan'}
            ref_list = {accounts:[1,2],contact_details:[6,5]}
            redis_store.save_refs store,'Person',person,ref_list,() ->        
                done()

    describe 'add_to_collection', () ->
        beforeEach (done) -> clear_db(done)
        it 'should add an object to a collection in the store', (done) ->
            store = {client:redis.createClient()}
            store.client.select debug_db
            johan = {id:2,name:'johan'}
            lorraine = {id:5,name:'lorraine'}
            redis_store.add_to_collection store,'People',lorraine,() ->
                redis_store.add_to_collection store,'People',johan,() ->
                    done()

    describe 'load_collection', () ->
        beforeEach (done) -> clear_db(done)
        it 'should load a collections ids', (done) ->
            store = {client:redis.createClient()}
            store.client.select debug_db
            johan = {id:2,name:'johan'}
            lorraine = {id:5,name:'lorraine'}
            redis_store.add_to_collection store,'People',lorraine,() ->
                redis_store.add_to_collection store,'People',johan,() ->
                    redis_store.load_collection store,'People',(ids)->
                        ids.length.should.equal 2
                        (2 in ids).should.equal true
                        (5 in ids).should.equal true
                        done()

    describe 'load', () ->
        beforeEach (done) -> clear_db(done)
        it 'should load an object from the store', (done) ->
            store = {client:redis.createClient()}
            store.client.select debug_db
            person = {id:2,name:'johan'}
            redis_store.save store,'Person',person,(saved_person) ->
                redis_store.load store,'Person',2,(loaded_person) ->
                    expect(loaded_person).to.exist
                    loaded_person.id.should.equal 2
                    loaded_person.name.should.equal 'johan'
                    done()

    describe 'load_refs', () ->
        beforeEach (done) -> clear_db(done)
        it 'should an objects refs to the store', (done) ->
            store = {client:redis.createClient()}
            store.client.select debug_db
            person = {id:2,name:'johan'}
            ref_list = {accounts:[1,2],contact_details:[6,5]}
            redis_store.save_refs store,'Person',person,ref_list,() ->
                redis_store.load_refs store,'Person',2,['accounts','contact_details'],(loaded_ref_list) ->
                    expect(loaded_ref_list).to.exist
                    expect(loaded_ref_list['accounts']).to.exist
                    loaded_ref_list['accounts'].length.should.equal 2
                    loaded_ref_list['accounts'][0].should.equal '1'
                    loaded_ref_list['accounts'][1].should.equal '2'
                    expect(loaded_ref_list['contact_details']).to.exist
                    loaded_ref_list['contact_details'].length.should.equal 2
                    loaded_ref_list['contact_details'][0].should.equal '5'
                    loaded_ref_list['contact_details'][1].should.equal '6'
                    done()
