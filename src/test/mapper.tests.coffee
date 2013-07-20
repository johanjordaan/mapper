if !define?
    define = require('amdefine')(module) 


define ['chai','../lib/mapper','./test_maps'], (chai,mapper,test_maps) ->
    should = chai.should();

    describe 'flatten', () ->
        it 'should flatten a hierachical structure', () ->
            bank = {name:'bank one'}
            person = {name:'johan',accounts:[{bank:bank},{bank:bank}]}
            flat_list = mapper.flatten test_maps.person_map,person
            flat_list.length.should.equal 3       

    describe 'apply', () ->
        it 'should apply action to the Simple type', () ->
            source = {name:'johan'}
            obj = {}
            mapper.apply test_maps.person_map,obj,source, actions =
                Simple : (field_name,field_def,obj,source) ->
                    obj[field_name] = source[field_name]
            ,(field_name,field,obj,source) ->
                    field_name in Object.keys source        


            obj['name'].should.equal source.name    

        it 'should apply action to the SimpleList type', () ->
            source = {lotto_numbers : [1,2,3]}
            obj = {}
            mapper.apply test_maps.person_map,obj,source, actions =
                SimpleList : (field_name,field_def,obj,source) ->
                    obj[field_name] = []
                    obj[field_name].push(x) for x in source[field_name]

            obj['lotto_numbers'].length.should.equal 3
            obj['lotto_numbers'][0].should.equal source.lotto_numbers[0]
            obj['lotto_numbers'][1].should.equal source.lotto_numbers[1]
            obj['lotto_numbers'][2].should.equal source.lotto_numbers[2]


        it 'should apply action to the List type', () ->
            source = {accounts:[{name:'savings'},{name:'loan'}]}
            obj = {}
            mapper.apply test_maps.person_map,obj,source, actions =
                List : (field_name,field_def,obj,source) ->
                    obj[field_name] = []
                    obj[field_name].push(x) for x in source[field_name] 

            obj['accounts'].length.should.equal 2
            obj['accounts'][0].name.should.equal source.accounts[0].name
            obj['accounts'][1].name.should.equal source.accounts[1].name

        it 'should apply action to the Ref type', () ->
            source = {contact_details:{email:"me@here.com"}}
            obj = {}
            mapper.apply test_maps.person_map,obj,source, actions =
                Ref : (field_name,field_def,obj,source) ->
                    obj[field_name] = 'Hallo' 

            obj['contact_details'].should.equal 'Hallo'

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


            



 
