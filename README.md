# LinuxLikeConsole ([v2.0.1](https://github.com/cobrapitz/LinuxLikeConsole/tree/v2.0.1))
### Linux Like Console written in gdscript for Godot (Game Engine)
###### For additional features or problems just write an issue, write an email or Discord cobrapitz#2872


![Console](https://github.com/cobrapitz/LinuxLikeConsole/blob/master/showcase/consoleFront.PNG)

###### toggle with: key above tab

***

## [Showcase](https://github.com/cobrapitz/LinuxLikeConsole/wiki/Showcase)

## [Wiki](https://github.com/cobrapitz/LinuxLikeConsole/wiki)

## [Changelog](https://github.com/cobrapitz/LinuxLikeConsole/wiki/Changelog)

***

## Features:
* [x] auto completion / suggestion
* [x] custom commands
* [x] dragable console
* [x] built in commands like
  * [x] /man [command]
  * [x] /help or /helpAll (shows user-defined/all commands)
  * [x] /exit (hides console)
  * [x] /alias [newName] [command] [args...]
* [x] slide in animation
* [x] predefined and runtime forwarded parameters (runtime forwarding is prioritized)
* [x] easy BBcode support (like: [b]this is bold[/b])
* [x] ~~ (simple) ~~  logging (improved in v2.1)
* [x] custom/built in themes (arch theme, ubuntu theme, windows, light, dark, **new** text_only (in v2.0))
* [x] user mode (commands have priviliges) (v1.1)
* [x] Additional Logging functions (warn, error, sucess ) (v2.1)
***
### Coming in next version:
- ~~Chat~~

***
### Fully customizeable

![functions](https://github.com/cobrapitz/LinuxLikeConsole/blob/master/showcase/console10.PNG)

***

### Drawbacks
* #### parameter access of custom functions with Arrays (see example below)
* #### window not resizeable (only with 'setDock' in runtime)


### How to create custom commands

##### [Short Version](https://github.com/cobrapitz/LinuxLikeConsole/wiki/Examples#1-how-to-add-custom-command-1)
```gdscript
#short version

const CommandRef = preload("res://console/command_ref.gd")
const Console = preload("res://console/console.tscn")

onready var console = $console


func _ready():
    var printRef = CommandRef.new(self, "my_print", CommandRef.COMMAND_REF_TYPE.FUNC, 1)
    var printCommand = Command.new('test_print', printRef, [], 'Custom print.', ConsoleRights.CallRights.USER)
    console.add_command(printCommand)

    
func my_print(input : Array):
    print("This is my first message: %s" % input[0]) 
```
