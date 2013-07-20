if !define?
    define = require('amdefine')(module) 

define ['chai','./test_maps','../lib/js_store'], (chai,test_maps,js_store) ->
    should = chai.should()
    expect = chai.expect

    describe 'get_id', () ->
        it 'it should get a new id from the store', (done) ->
            store = {}
            js_store.get_id store,'test',(id) -> 
                id.should.equal = 1
                store['test'].should.equal 1 
                done()

    describe 'save', () ->
        it 'should save an object to the store', (done) ->
            store = {}
            person = {id:2,name:'johan'}
            js_store.save store,'Person',person,(saved_person) ->
                expect(store['Person:2']).to.exist
                saved_person.name.should.equal 'johan'
                saved_person.id.should.equal 2
                done()

    describe 'save_refs', () ->
        it 'should save an objects refs to the store', (done) ->
            store = {}
            person = {id:2,name:'johan'}
            ref_list = {accounts:[1,2],contact_details:[6,5]}
            js_store.save_refs store,'Person',person,ref_list,() ->
                expect(store['Person:2:accounts']).to.exist
                store['Person:2:accounts'].length.should.equal 2
                store['Person:2:accounts'][0].should.equal 1
                store['Person:2:accounts'][1].should.equal 2                
                expect(store['Person:2:contact_details']).to.exist
                store['Person:2:contact_details'].length.should.equal 2
                store['Person:2:contact_details'][0].should.equal 6
                store['Person:2:contact_details'][1].should.equal 5             
                done()

    describe 'add_to_collection', () ->
        it 'should add an object to a collection in the store', (done) ->
            store = {}
            johan = {id:2,name:'johan'}
            lorraine = {id:5,name:'lorraine'}
            js_store.add_to_collection store,'People',lorraine,() ->
                expect(store['People']).to.exist
                store['People'].length.should.equal 1
                store['People'][0].should.equal 5
                js_store.add_to_collection store,'People',johan,() ->
                    store['People'].length.should.equal 2
                    store['People'][1].should.equal 2
                    done()

    describe 'load', () ->
        it 'should load an object from the store', (done) ->
            store = {}
            person = {id:2,name:'johan'}
            js_store.save store,'Person',person,(saved_person) ->
                expect(store['Person:2']).to.exist
                js_store.load store,'Person',2,(loaded_person) ->
                    expect(loaded_person).to.exist
                    loaded_person.id.should.equal 2
                    loaded_person.name.should.equal 'johan'
                    done()

    describe 'load_refs', () ->
        it 'should an objects refs to the store', (done) ->
            store = {}
            person = {id:2,name:'johan'}
            ref_list = {accounts:[1,2],contact_details:[6,5]}
            js_store.save_refs store,'Person',person,ref_list,() ->
                js_store.load_refs store,'Person',2,['accounts','contact_details'],(loaded_ref_list) ->
                    expect(loaded_ref_list).to.exist
                    expect(loaded_ref_list['accounts']).to.exist
                    loaded_ref_list['accounts'].length.should.equal 2
                    loaded_ref_list['accounts'][0].should.equal 1
                    loaded_ref_list['accounts'][1].should.equal 2
                    expect(loaded_ref_list['contact_details']).to.exist
                    loaded_ref_list['contact_details'].length.should.equal 2
                    loaded_ref_list['contact_details'][0].should.equal 6
                    loaded_ref_list['contact_details'][1].should.equal 5
                    done()
