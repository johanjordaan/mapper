if !define?
    define = require('amdefine')(module) 

define [], () ->
	###
	person_map = 
		model_name 	: 'Person'
		fields :
			name 	 				: { type:'Simple', default_value:'*name*' }
			surname	 				: { type:'Simple', default_value:'*surname*' }
			age		 				: { type:'Simple', default_value:10,conversion:Number }
			contact_details			: { type:'Ref', map:contact_detail_map, internal:true }
			extra_contact_details	: { type:'Ref', map:contact_detail_map, internal:true }
			accounts 				: { type:'List', map : account_map, internal : true }
			lotto_numbers			: { type:'SimpleList', default_value:[], conversion:Number }
		default_collection : 'People'
	###

	field_type_map = 
		model_name : 'FieldType'
		default_collection : 'FieldTypes'
		fields:
			name  			: {type:'Simple',default_value:'*name*'}
			description     : {type:'Simple',default_value:'*name*'}

	field_map =
		model_name : 'Field'
		default_collection : 'Fields'
		fields:
			type 			: {type:'Ref',map:field_type_map}
			default_value	: {type:'Simple',default_value:'*default_value*'}
			map 			: {type:'Ref'}
			internal 		: {type:'Simple',conversion:(v) -> Boolean(Number(v))}
			conversion		: {type:'Simple'}

	map_map =
		model_name : 'Map'
		default_collection : 'Maps'
		fields :
			model_name			: {type:'Simple',default_value:'*model_name*'}
			fields 				: {type:'List',map:field_map}
			default_collection	: {type:'Simple',default_value:'*default_collection*'}

	field_map.fields.map.map = map_map		

	console.log field_map.fields.map.map 