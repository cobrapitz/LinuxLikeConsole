# LinuxLikeConsole
### Linux Like Console written in gdscript for Godot (Game Engine)
###### For additional features or problems just write an issue, write an email or Discord cobrapitz#2872


![Console](https://i.ibb.co/DG0qmN2/LLC.png)

##### toggle with: key above tab

[click for more pictures](https://github.com/cobrapitz/LinuxLikeConsole/wiki/Showcase)

## ![Wiki](https://github.com/cobrapitz/LinuxLikeConsole/wiki)

## Features:
* [x] auto completion / suggestion
* [x] custom commands
* [x] dragable console
* [x] built in commands like
  * [x] /man [command]
  * [x] /help (shows user defined commands)
  * [x] /exit (hides console)
  * [x] /clear (clears text history)
  * [x] /helpAll (shows all commands)
  * [x] /alias [newName] [command] [args...]
* [x] slide in animation
* [x] predefined and runtime forwarded parameters (runtime forwarding is prioritized)
* [x] easy BBcode support (like: [b]this is bold[/b])
* [x] (simple) logging 
* [x] custom/built in themes (arch theme, ubuntu theme, windows, light, dark)

![functions](https://i.imgur.com/7740jiH.png)

### Drawbacks
* #### parameter access of custom functions with Arrays (see example below)
* #### window not resizeable (only with 'setDock' in runtime)


### How to create custom commands

##### [Short Version](https://github.com/cobrapitz/LinuxLikeConsole/wiki/Examples#1-how-to-add-custom-command-1)
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

    # more practical example 
    # note: number of args can vary
    var bgColorRef = CommandRef.new(self, "change_background_color", CommandRef.COMMAND_REF_TYPE.FUNC, [3,4])
    var bgColorCommand = Command.new('changeBackgroundColor', bgColorRef, [], 'Changes the color of the background.')
    testConsole.add_command(bgColorCommand)

# called with: /test_print hello
# result: "This is my first message: hello" (in godot console)
func my_print(input : Array):
    print("This is my first message: %s" % input[0]) 
	
# called with: /changeBackgroundColor 0 1 0 1 
# OR with: /changeBackgroundColor 0 1 0
# result: changed background color of ColorRect to green -> Color(0, 1, 0, 1)
func change_background_color(input : Array):
    var bg = get_node(background) as ColorRect
    var c = input # color c
    if c.size() == 3: 
        bg.set_frame_color(Color(c[0], c[1], c[2], 1))
    else: # 4
        bg.set_frame_color(Color(c[0], c[1], c[2], c[3]))
```
