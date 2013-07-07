if !define?
	define = require('amdefine')(module) 


define [], () ->
	create = () ->
		ctx =
			count : 0
			results : []	

	call = (ctx) ->
		func = arguments['1']
	
		# It is assumed that func is a function and that the last of its arguments is a callback
		# The callback is replaced with our own wrapper and called within the context of the wrapper
		# 
	
		args = Array.prototype.slice.call arguments, 2
		old_callback = args[args.length-1]
		
		if typeof old_callback == 'function'
			ctx.count++
			args[args.length-1] = () ->
				args2 = Array.prototype.slice.call arguments
				if args2.length == 1 				
					ctx.results.push args2[0]		# Need to handle multiple 'return' values
				old_callback.apply(this,args2)
				ctx.count--
				finalise

			func.apply this,args
		else
			ctx.count++
			ctx.results.push func.apply(this,args)
			ctx.count--
			finalise

	finalise = (ctx,f) ->
		if !f?
			ctx.f = f
		
		if ctx.count == 0 
			if !ctx.f?			
				ctx.f ctx.results
			

	exports =
		create:create 
		call:call
		finalise:finalise