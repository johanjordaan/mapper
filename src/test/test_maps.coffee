if !define?
	define = require('amdefine')(module) 


define [], () ->
	bank_map =
		model_name	: 'Bank'
		fields 	:
			name 	 : { type:'Simple', default_value:'*name*' }
		default_collection : 'Banks'

	contact_detail_map = 
		model_name	: 'ContactDetail'	
		fields 	: 
			cel_no 	 : { type:'Simple', default_value:'*cel_no*' }
			tel_no 	 : { type:'Simple', default_value:'*tel_no*' }
			email 	 : { type:'Simple', default_value:'*email*' }
		default_collection : 'ContactDetails'


	account_map = 
		model_name	: 'Account'
		fields	: 
			type 	: { type:'Simple', default_value:'*type*' }
			bank	: { type:'Ref', map:bank_map, internal:false }
		default_collection : 'Accounts'

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

	user_map =
		model_name	: 'User'
		id_field	: 'email'
		fields : 
			email		: { type:'Simple', default_value:'*email*' }
			model_name	: {	type:'Simple', default_value:'*name*' }	
			password 	: { type:'Simple', default_value:'*password*'}
		default_collection : 'Users'

	exports = 
		bank_map:bank_map
		contact_detail_map:contact_detail_map
		account_map:account_map
		person_map:person_map
		user_map:user_map
