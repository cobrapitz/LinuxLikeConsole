extends Reference

class_name Command

const CommandRef = preload("res://console/command_ref.gd")

var _name : String
var _cmdRef 
var _args : Array
var _description : String = ""

func _init(name : String, cmdRef, args : Array, description : String):
	_name = name
	_cmdRef = cmdRef
	_args = args
	_description = description 

func apply(args : Array):
	if args.empty():
		_cmdRef.apply(_args)
	else:
		_cmdRef.apply(args)
		

func set_name(name : String):
	_name = name
	
func set_ref(cmdRef):
	_cmdRef = cmdRef
	
func set_args(args : Array):
	_args = args
	
func set_description(description : String):
	_description = description

func get_ref():
	return _cmdRef

func get_name() -> String:
	return _name
	
func get_args() -> Array:
	return _args
	
func get_description() -> String:
	return _description