extends Node

class_name DefaultCommands

var _firstHelp := true

#const Console = preload("res://console/console.gd") #!cyclic

var _consoleRef #: Console


func _init(console):
	_consoleRef = console
	var exitRef = CommandRef.new(self, "exit", CommandRef.COMMAND_REF_TYPE.FUNC, 0)
	var exitCommand = Command.new('exit',  exitRef, [], 'Closes the console.')
	console.add_command(exitCommand)
	
	var clearRef = CommandRef.new(self, "clear", CommandRef.COMMAND_REF_TYPE.FUNC, 0)
	var clearCommand = Command.new('clear', clearRef, [], 'Clears the console.')
	console.add_command(clearCommand)
	
	var manRef = CommandRef.new(self, "man", CommandRef.COMMAND_REF_TYPE.FUNC, 1)
	var manCommand = Command.new('man', manRef, [], 'shows command description.')
	console.add_command(manCommand)
	
	var helpRef = CommandRef.new(self, "help", CommandRef.COMMAND_REF_TYPE.FUNC, 0)
	var helpCommand = Command.new('help', helpRef, [], 'shows all user defined commands.')
	console.add_command(helpCommand)
	
	var helpAllRef = CommandRef.new(self, "help_all", CommandRef.COMMAND_REF_TYPE.FUNC, 0)
	var helpAllCommand = Command.new('helpAll', helpAllRef, [], 'shows all commands.')
	console.add_command(helpAllCommand)
	
	var incSizeRef = CommandRef.new(self, "increase_size", CommandRef.COMMAND_REF_TYPE.FUNC, [0, 1, 2])
	var incSizeCommand = Command.new('++', incSizeRef, [], 'Increases the command size width.')
	console.add_command(incSizeCommand)
	
	var decSizeRef = CommandRef.new(self, "decrease_size", CommandRef.COMMAND_REF_TYPE.FUNC, [0, 1, 2])
	var decSizeCommand = Command.new('--', decSizeRef, [], 'Decreases the command size width.')
	console.add_command(decSizeCommand)
	
	var setCommandSignRef = CommandRef.new(self, "set_command_sign", CommandRef.COMMAND_REF_TYPE.FUNC, 1)
	var setCommandSignCommand = Command.new('setCommandSign', setCommandSignRef, [], 'Sets new command sign. (default: \'/\')')
	console.add_command(setCommandSignCommand)
	
	var toggleButtonRef = CommandRef.new(self, "toggle_button", CommandRef.COMMAND_REF_TYPE.FUNC, 0)
	var toggleButtonCommand = Command.new('toggleButton', toggleButtonRef, [], 'Toggles visibility of \'send\' button.')
	console.add_command(toggleButtonCommand)
	
	var toggleEditLineRef = CommandRef.new(self, "toggle_edit_line", CommandRef.COMMAND_REF_TYPE.FUNC, 0)
	var toggleEditLineCommand = Command.new('toggleShowEditLine', toggleEditLineRef, [], 'Toggles visibility of edit line.')
	console.add_command(toggleEditLineCommand)
	
	var setUserMessageSignRef = CommandRef.new(self, "set_user_msg_sign", CommandRef.COMMAND_REF_TYPE.FUNC, 1)
	var setUserMessageSignCommand = Command.new('setUserMessageSign', setUserMessageSignRef, [], 'Sets new sign for user messages. (default: \'>\')')
	console.add_command(setUserMessageSignCommand)
	
	var toggleNewLineAfterRef = CommandRef.new(self, "toggle_add_new_line_after_cmd", CommandRef.COMMAND_REF_TYPE.FUNC, 0)
	var toggleNewLineAfterCommand = Command.new('toggleNewLineAfterCommand', toggleNewLineAfterRef, [], 'Toggles new line after commands. (default: \'off\'')
	console.add_command(toggleNewLineAfterCommand)
	
	var toggleWindowDragRef = CommandRef.new(self, "toggle_window_drag", CommandRef.COMMAND_REF_TYPE.FUNC, 0)
	var toggleWindowDragCommand = Command.new('toggleWindowDrag', toggleWindowDragRef, [], 'Toggles whether the console is draggable or not.')
	console.add_command(toggleWindowDragCommand)
	
	var setThemeRef = CommandRef.new(self, "set_theme", CommandRef.COMMAND_REF_TYPE.FUNC, 1)
	var setThemeCommand = Command.new('setTheme', setThemeRef, [], 'Sets the theme.')
	console.add_command(setThemeCommand)
	
	var setDockRef = CommandRef.new(self, "set_dock", CommandRef.COMMAND_REF_TYPE.FUNC, 1)
	var setDockCommand = Command.new('setDock', setDockRef, [], 'Sets the docking station.')
	console.add_command(setDockCommand)
	
	var setTextColorRef = CommandRef.new(self, "set_default_text_color", CommandRef.COMMAND_REF_TYPE.FUNC, [1,3,4])
	var setTextColorCommand = Command.new('setDefaultTextColor', setTextColorRef, [], 'Sets the default text color.')
	console.add_command(setTextColorCommand)

	
#	var sendRef = CommandRef.new(self, "send", CommandRef.COMMAND_REF_TYPE.FUNC, _consoleRef.VARIADIC_COMMANDS)
#	var sendCommand = Command.new('send', sendRef, [], 'send.')
#	console.add_command(sendCommand)


# default commands

#func send(input : Array):
#	var output := ""
#	for i in range(input.size()):
#		output += input[i]
#
#	_consoleRef.append_message(output)

func set_default_text_color(input : Array):
	if input.size() == 1:
		_consoleRef.update_text_color(input[0])
	elif input.size() == 3:
		_consoleRef.set_default_text_color(Color(input[0], input[1], input[2])) 
	elif input.size() == 4:
		_consoleRef.set_default_text_color(Color(input[0], input[1], input[2], input[3])) 
	 

func set_dock(input : Array):
	_consoleRef.update_docking(input[0])
	
	
func set_theme(input : Array):
	_consoleRef.update_theme(input[0])
	

func help_all(_input : Array):
	_consoleRef.new_line()
	for i in range(_consoleRef.commands.size()):
		_consoleRef.append_message_no_event("%s%s" % [_consoleRef.commandSign, _consoleRef.commands[i].get_name()], true)
		_consoleRef.append_message_no_event(": %s" % _consoleRef.commands[i].get_description())
		_consoleRef.append_message_no_event(" (args: ")
		_consoleRef._print_args(i)
		_consoleRef.append_message_no_event(")")
		_consoleRef.new_line()


func set_command_sign(input : Array):
	_consoleRef.commandSign = input[0]

	
func toggle_button(_input : Array):
	_consoleRef.showButton = ! _consoleRef.showButton
	if _consoleRef.has_node("offset/send") and _consoleRef.get_node("offset/send") != null:
		_consoleRef.get_node("offset/send").visible = _consoleRef.showButton
	if _consoleRef.has_node("offset/lineEdit") and _consoleRef.get_node("offset/lineEdit") != null:
		if _consoleRef.showButton:
			_consoleRef.get_node("offset/lineEdit").margin_right = -66
		else:
			_consoleRef.get_node("offset/lineEdit").margin_right = -5

	
func toggle_edit_line(_input : Array):
	_consoleRef.showLine = ! _consoleRef.showLine
	if _consoleRef.has_node("offset/textBackground") and _consoleRef.get_node("offset/textBackground") != null:
		if _consoleRef.showLine:
			_consoleRef.get_node("offset/textBackground").margin_bottom = -21
		else:
			_consoleRef.get_node("offset/textBackground").margin_bottom = 0
	
	
func set_user_msg_sign(input : Array):
	_consoleRef.update_lineEdit(input[0])
	
	
func toggle_add_new_line_after_cmd(_input : Array):
	_consoleRef.addNewLineAfterCommand = ! _consoleRef.addNewLineAfterCommand
	
	
func toggle_window_drag(_input : Array):
	_consoleRef.enableWindowDrag = ! _consoleRef.enableWindowDrag

	
func increase_size(input : Array):
	if input.size() == 0:
		_consoleRef.rect_size.x += _consoleRef.rect_size.x / 2.0
	elif input.size() == 1:
		if str(input[0]).to_lower() == "h":
			_consoleRef.rect_size.y += _consoleRef.rect_size.y / 2.0
		elif str(input[0]).to_lower() == "w":
			_consoleRef.rect_size.x += _consoleRef.rect_size.x / 2.0
	elif input.size() == 2:
		if (str(input[0]).to_lower() == "h" and str(input[1]).to_lower() == "w") or \
				(str(input[1]).to_lower() == "h" and str(input[0]).to_lower() == "w"):
			_consoleRef.rect_size.x += _consoleRef.rect_size.x / 2.0
			_consoleRef.rect_size.y += _consoleRef.rect_size.y / 2.0
			
func decrease_size(input : Array):
	if input.size() == 0:
		_consoleRef.rect_size.x -= _consoleRef.rect_size.x / 2.0
	elif input.size() == 1:
		if str(input[0]).to_lower() == "h":
			_consoleRef.rect_size.y -= _consoleRef.rect_size.y / 2.0
		elif str(input[0]).to_lower() == "w":
			_consoleRef.rect_size.x -= _consoleRef.rect_size.x / 2.0
	elif input.size() == 2:
		if (str(input[0]).to_lower() == "h" and str(input[1]).to_lower() == "w") or \
				(str(input[1]).to_lower() == "h" and str(input[0]).to_lower() == "w"):
			_consoleRef.rect_size.x -= _consoleRef.rect_size.x / 2.0
			_consoleRef.rect_size.y -= _consoleRef.rect_size.y / 2.0
			


func clear(_input : Array):
	_consoleRef.textLabel.clear()
	
	
func exit(_input : Array):
	_consoleRef.toggle_console()
	
	
func man(input : Array):
	var command = input[0]
	
	_consoleRef.new_line()
	for i in range(_consoleRef.commands.size()):
		if _consoleRef.commands[i].get_name() == command:
			_consoleRef.append_message_no_event("%s%s" % [_consoleRef.commandSign, _consoleRef.commands[i].get_name()], true)
			_consoleRef.append_message_no_event(": %s" % _consoleRef.commands[i].get_description())
			_consoleRef.append_message_no_event(" (args: ")
			_consoleRef._print_args(i)
			_consoleRef.append_message_no_event(")")
			_consoleRef.new_line()
			return
	
	_consoleRef.append_message_no_event("[color=red]Couldn't find command '%s'[/color]" % command)
		
	
func help(_input : Array):
	if _firstHelp:
		_firstHelp = false
		_consoleRef.append_message_no_event("'help' shows user added commands. Use 'helpAll' to show all commands")
		_consoleRef.new_line()
	
	_consoleRef.new_line()
	for ti in range(_consoleRef.commands.size() - _consoleRef.basicCommandsSize):
		var i = ti + _consoleRef.basicCommandsSize
		_consoleRef.append_message_no_event("%s%s" % [_consoleRef.commandSign, _consoleRef.commands[i].get_name()], true)
		_consoleRef.append_message_no_event(": %s" % _consoleRef.commands[i].get_description())
		_consoleRef.append_message_no_event(" (args: ")
		_consoleRef._print_args(i)
		_consoleRef.append_message_no_event(")")
		_consoleRef.new_line()
		
