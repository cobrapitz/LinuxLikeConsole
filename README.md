# LinuxLikeConsole
### Linux Like Console written in gdscript for Godot (Game Engine)



![Console](https://i.ibb.co/DG0qmN2/LLC.png)

toggle with: key above tab


## Features:
* #### auto completion / suggestion
* #### custom commands
* #### custom command sign (default: '/')
* #### built in commands like
  * /man <command>
  * /help (shows all commands)
  * /exit (hides console)
  * /clear (clears text history)
* #### slide in animation
* #### predefined and runtime forwarded parameters (runtime forwarding is prioritized)

### Drawbacks
* #### parameter access of custom functions with Arrays 


### How to create custom commands

```gdscript
const CommandRef = preload("res://console/command_ref.gd")
const Console = preload("res://console/console.tscn")

onready var testConsole = $console


func _ready():
  # CommandRef: 
  # @param1: object, that owns the reference (function)
  # @param2: method name
  # @param3: type (FUNC or VAR)
  # @param4: expected amount of parameters
	var exitRef = CommandRef.new(self, "my_print", CommandRef.COMMAND_REF_TYPE.FUNC, 1)
 
  # CommandRef: 
  # @param1: how to call the name in the console (here: /test_print)
  # @param2: CommandRef you created before
  # @param3: predefined parameters
  # @param4: description, can be shown by /help or /man <command>
  var exitCommand = Command.new('test_print', exitRef, [], 'Custom print.')
	testConsole.add_command(exitCommand)


func my_print(message : Array):
	print("This is my first message: %s" % message[0] 
```
  
#### Godots 'tool' keyword

* ##### Custom command sign (default: '/')
* ##### Show button
* ##### Custom user message sign (default: '$')
