mapper
======


Description
-----------
mapper is a very simple model mapping piece of software

Features
-----------


Examples
-----------
1) Create a new map

person_map = 
	model_name : 'Person'	// See this as the table name
	fields:
		name 	: { type:'Simple', default_value:'*Name*'} 
		surname : { type:'Simple', default_value:'*Name*'} 


/admin/list_maps
	Screen with list of maps
	Button to add a map

/admin/edit_map
	Screen with abilty to add a new map
	Has the ability to CRUD fields
	Only shows fields that are part of the map




