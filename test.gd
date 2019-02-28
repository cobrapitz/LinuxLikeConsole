tool
extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const CommandRef = preload("res://console/command_ref.gd")
const Console = preload("res://console/console.tscn")

onready var testConsole = $console

# Called when the node enters the scene tree for the first time.
func _ready():
	var exitRef = CommandRef.new(self, "my_print", CommandRef.COMMAND_REF_TYPE.FUNC, 1)
	var exitCommand = Command.new('test_print', exitRef, [], 'Custom print.')
	testConsole.add_command(exitCommand)
	
	#add_child(testConsole)


func my_print(message : Array):
	print("This is my first message: %s" % message[0] )

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
