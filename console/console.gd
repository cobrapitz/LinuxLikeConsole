"""
- contains a list of commands (Commands.gd)
"""
tool
extends Control

class_name Console

# signals
signal on_message_sent
signal on_command_sent

# types
const Command = preload("res://console/command.gd")
const CommandRef = preload("res://console/command_ref.gd")

#var logFile = preload("res://Log.gd").new()

onready var lineEdit = $offset/lineEdit
onready var textLabel = $offset/richTextLabel
onready var animation = $offset/animation

#var allText = ""
var messageHistory := ""
var messages := []
var currentIndex := -1
var resetSwitch := true

var startWindowDragPos : Vector2
var dragging : bool


var commands := []
var basicCommandsSize := 0

var firstHelp := true

var isShown := true

const toggleConsole = KEY_QUOTELEFT

# export vars

export(String) var next_message_history = "ui_down"
export(String) var previous_message_history = "ui_up"
export(String) var autoComplete = "ui_focus_next"
export(String) var commandSign := "/"
export(bool) var showButton = false setget update_visibility_button
export(bool) var showLine = false setget update_visibility_line
export(String) var userMessageSign = ">" setget update_lineEdit
export(bool) var addNewLineAfterCommand = false 
export(bool) var enableWindowDrag = true 


func update_lineEdit(text : String):
	userMessageSign = text
	if has_node("offset/lineEdit") and $offset/lineEdit != null:
		$offset/lineEdit.set_placeholder(text)
		

func update_visibility_button(show):
	showButton = show
	if has_node("offset/send") and $offset/send != null:
		$offset/send.visible = show
	if has_node("offset/lineEdit") and $offset/lineEdit != null:
		if show:
			$offset/lineEdit.margin_right = -66
		else:
			$offset/lineEdit.margin_right = -5
			
func update_visibility_line(show):
	showLine = show
	if has_node("offset/textBackground") and $offset/textBackground != null:
		if show:
			$offset/textBackground.margin_bottom = -19
		else:
			$offset/textBackground.margin_bottom = 0
			

func _init():
	set_process_input(true)
	add_basic_commands()
	basicCommandsSize = commands.size()
	
	
func add_basic_commands():
	var exitRef = CommandRef.new(self, "exit", CommandRef.COMMAND_REF_TYPE.FUNC, 0)
	var exitCommand = Command.new('exit',  exitRef, [], 'Closes the console.')
	add_command(exitCommand)
	
	var clearRef = CommandRef.new(self, "clear", CommandRef.COMMAND_REF_TYPE.FUNC, 0)
	var clearCommand = Command.new('clear', clearRef, [], 'Clears the console.')
	add_command(clearCommand)
	
	var manRef = CommandRef.new(self, "man", CommandRef.COMMAND_REF_TYPE.FUNC, 1)
	var manCommand = Command.new('man', manRef, [], 'shows command description.')
	add_command(manCommand)
	
	var helpRef = CommandRef.new(self, "help", CommandRef.COMMAND_REF_TYPE.FUNC, 0)
	var helpCommand = Command.new('help', helpRef, [], 'shows all user defined commands.')
	add_command(helpCommand)
	
	var helpAllRef = CommandRef.new(self, "help_all", CommandRef.COMMAND_REF_TYPE.FUNC, 0)
	var helpAllCommand = Command.new('helpAll', helpAllRef, [], 'shows all commands.')
	add_command(helpAllCommand)
	
	var incSizeRef = CommandRef.new(self, "increase_size", CommandRef.COMMAND_REF_TYPE.FUNC, [0, 1, 2])
	var incSizeCommand = Command.new('++', incSizeRef, [], 'Increases the command size width.')
	add_command(incSizeCommand)
	
	var decSizeRef = CommandRef.new(self, "decrease_size", CommandRef.COMMAND_REF_TYPE.FUNC, [0, 1, 2])
	var decSizeCommand = Command.new('--', decSizeRef, [], 'Decreases the command size width.')
	add_command(decSizeCommand)
	
	var setCommandSignRef = CommandRef.new(self, "set_command_sign", CommandRef.COMMAND_REF_TYPE.FUNC, 1)
	var setCommandSignCommand = Command.new('setCommandSign', setCommandSignRef, [], 'Sets new command sign. (default: \'/\')')
	add_command(setCommandSignCommand)
	
	var toggleButtonRef = CommandRef.new(self, "toggle_button", CommandRef.COMMAND_REF_TYPE.FUNC, 0)
	var toggleButtonCommand = Command.new('toggleButton', toggleButtonRef, [], 'Toggles visibility of \'send\' button.')
	add_command(toggleButtonCommand)
	
	var toggleEditLineRef = CommandRef.new(self, "toggle_edit_line", CommandRef.COMMAND_REF_TYPE.FUNC, 0)
	var toggleEditLineCommand = Command.new('toggleShowEditLine', toggleEditLineRef, [], 'Toggles visibility of edit line.')
	add_command(toggleEditLineCommand)
	
	var setUserMessageSignRef = CommandRef.new(self, "set_user_msg_sign", CommandRef.COMMAND_REF_TYPE.FUNC, 1)
	var setUserMessageSignCommand = Command.new('setUserMessageSign', setUserMessageSignRef, [], 'Sets new sign for user messages. (default: \'>\')')
	add_command(setUserMessageSignCommand)
	
	var toggleNewLineAfterRef = CommandRef.new(self, "toggle_add_new_line_after_cmd", CommandRef.COMMAND_REF_TYPE.FUNC, 0)
	var toggleNewLineAfterCommand = Command.new('toggleNewLineAfterCommand', toggleNewLineAfterRef, [], 'Toggles new line after commands. (default: \'off\'')
	add_command(toggleNewLineAfterCommand)
	
	var toggleWindowDragRef = CommandRef.new(self, "toggle_window_drag", CommandRef.COMMAND_REF_TYPE.FUNC, 0)
	var toggleWindowDragCommand = Command.new('toggleWindowDrag', toggleWindowDragRef, [], 'Toggles whether the console is draggable or not.')
	add_command(toggleWindowDragCommand)


func _input(event):
	if event is InputEventKey and event.scancode == toggleConsole and event.is_pressed() and not event.is_echo():
		toggle_console()
		
	
	# left or right mouse button pressed
	# test if really needed
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT or event.button_index == BUTTON_RIGHT:
			if event.position.x < get_position().x or event.position.y < get_position().y \
					or event.position.x > get_position().x + get_size().x or event.position.y > get_position().y + get_size().y:
				lineEdit.focus_mode = FOCUS_NONE
			else:
				lineEdit.focus_mode = FOCUS_CLICK
	
	if Input.is_key_pressed(KEY_ENTER):
		if not lineEdit.text.empty():
			var tmp = lineEdit.text
			send_message_without_event("\n" + userMessageSign + " ", false, false)
			send_message(tmp)
		
			
	elif event.is_action_pressed(previous_message_history):
		if resetSwitch:
			messages.append(lineEdit.text)
			resetSwitch = false
		currentIndex -= 1
		if currentIndex < 0:
			currentIndex = messages.size() - 1
		lineEdit.text = messages[currentIndex]
		
	elif event.is_action_pressed(next_message_history):
		if resetSwitch:
			messages.append(lineEdit.text)
			resetSwitch = false
		currentIndex += 1
		if currentIndex > messages.size() - 1:
			currentIndex = 0
		lineEdit.text = messages[currentIndex]
		
	if event.is_action_pressed(autoComplete):
		var closests = get_closest_commands(lineEdit.text)
		print(closests)
		if  closests != null:
			if closests.size() == 1:
				lineEdit.text = commandSign + closests[0]
				lineEdit.set_cursor_position(lineEdit.text.length())
			elif closests.size() > 1:
				var tempLine = lineEdit.text
				send_message_without_event("possible commands: ")
				for c in closests:
					send_message_without_event(commandSign + c, true)
					messages.append(commandSign + c)
				#send_message_without_event("Press [Up] or [Down] to cycle through available commands.", false)
				lineEdit.text = tempLine
				lineEdit.set_cursor_position(lineEdit.text.length())


func _process(delta):
	if dragging and enableWindowDrag:
		rect_global_position = get_global_mouse_position() - startWindowDragPos


func toggle_console() -> void:
	if isShown:
		hide()
	else:
		show()
		play_animation()
		lineEdit.grab_focus()
		
	isShown = !isShown

func get_last_message() -> String:
	return messages.back()
	

func play_animation() -> void:
	animation.play("slide_in_console")
	

func grab_line_focus() -> void:
	lineEdit.focus_mode = Control.FOCUS_ALL
	lineEdit.grab_focus()
	
	
func add_command(command : Command) -> void:
	commands.append(command)
	
func remove_command(commandName : String) -> bool:
	for i in range(commands.size()):
		if commands[i].get_name() == commandName:
			commands.remove(i)
			return true
	return false
	
	
func send_message(message : String):
	if message.empty():
		return
		
	if not resetSwitch:
		messages.pop_back()
	resetSwitch = true
	
	# let the message be switched through
	messages.append(message)
	currentIndex += 1
	messageHistory += message
	
	# logging
	#logFile.write_log(message)
	
	# check if the input is a command
	if message[0] == commandSign:
		var currentCommand = message
		currentCommand = currentCommand.trim_prefix(commandSign)
		if is_input_real_command(currentCommand):
			# return the command and the whole message
			var cmd = get_command(currentCommand)
			if cmd == null:
				textLabel.add_text("Command not found!\n")
				return
			
			var found = false
			for i in range(commands.size()):
				if commands[i].get_name() == cmd.get_name(): # found command
					textLabel.add_text(message)
					
					textLabel.newline()
					found = true
					var args = _extract_arguments(currentCommand)
					if not args.size() in cmd.get_ref().get_expected_arguments():
						send_message_without_event("expected: ", false, false) 
						_print_args(i)
						send_message_without_event(" arguments!", false, false)
						
						if addNewLineAfterCommand:
							textLabel.newline()
					else:
						cmd.apply(_extract_arguments(currentCommand))
						
					emit_signal("on_command_sent", cmd, currentCommand)
					break
			if not found:
				textLabel.add_text("Commnd not found!\n")
		else:
			textLabel.add_text("Command not found!\n")
	else:
		textLabel.add_text(message)
	#textLabel.newline()
		
	emit_signal("on_message_sent", lineEdit.text)
	lineEdit.clear()



# default commands


func help_all(input : Array):
	for i in range(commands.size()):
		send_message_without_event("%s%s" % [commandSign, commands[i].get_name()], true, false)
		send_message_without_event(": %s" % commands[i].get_description(), false, false)
		send_message_without_event(" (args: ", false, false)
		_print_args(i)
		send_message_without_event(")") # new line


func set_command_sign(input : Array):
	commandSign = input[0]

	
func toggle_button(input : Array):
	showButton = ! showButton
	if has_node("offset/send") and $offset/send != null:
		$offset/send.visible = showButton
	if has_node("offset/lineEdit") and $offset/lineEdit != null:
		if showButton:
			$offset/lineEdit.margin_right = -66
		else:
			$offset/lineEdit.margin_right = -5

	
func toggle_edit_line(input : Array):
	showLine = ! showLine
	if has_node("offset/textBackground") and $offset/textBackground != null:
		if showLine:
			$offset/textBackground.margin_bottom = -19
		else:
			$offset/textBackground.margin_bottom = 0
	
	
func set_user_msg_sign(input : Array):
	update_lineEdit(input[0])
	
	
func toggle_add_new_line_after_cmd(input : Array):
	addNewLineAfterCommand = ! addNewLineAfterCommand
	
	
func toggle_window_drag(input : Array):
	enableWindowDrag = ! enableWindowDrag

	
func increase_size(input : Array):
	if input.size() == 0:
		rect_size.x += rect_size.x / 2.0
	elif input.size() == 1:
		if str(input[0]).to_lower() == "h":
			rect_size.y += rect_size.y / 2.0
		elif str(input[0]).to_lower() == "w":
			rect_size.x += rect_size.x / 2.0
	elif input.size() == 2:
		if (str(input[0]).to_lower() == "h" and str(input[1]).to_lower() == "w") or \
				(str(input[1]).to_lower() == "h" and str(input[0]).to_lower() == "w"):
			rect_size.x += rect_size.x / 2.0
			rect_size.y += rect_size.y / 2.0
			
func decrease_size(input : Array):
	if input.size() == 0:
		rect_size.x -= rect_size.x / 2.0
	elif input.size() == 1:
		if str(input[0]).to_lower() == "h":
			rect_size.y -= rect_size.y / 2.0
		elif str(input[0]).to_lower() == "w":
			rect_size.x -= rect_size.x / 2.0
	elif input.size() == 2:
		if (str(input[0]).to_lower() == "h" and str(input[1]).to_lower() == "w") or \
				(str(input[1]).to_lower() == "h" and str(input[0]).to_lower() == "w"):
			rect_size.x -= rect_size.x / 2.0
			rect_size.y -= rect_size.y / 2.0
			


func clear(msg):
	textLabel.clear()
	
	
func exit(msg):
	toggle_console()
	
	
func man(command):
	for i in range(commands.size()):
		if commands[i].get_name() == command[0]:
			send_message_without_event("%s%s" % [commandSign, commands[i].get_name()], true, false)
			send_message_without_event(": %s" % commands[i].get_description(), false, false)
			send_message_without_event(" (args: ", false, false)
			_print_args(i)
			send_message_without_event(")", false, false)
			return
	send_message_without_event("Couldn't find command '%s'" % command)
		
	
func help(input : Array):
	if firstHelp:
		firstHelp = false
		send_message_without_event("'help' shows user added commands. Use 'helpAll' to show all commands")
	
	for ti in range(commands.size() - basicCommandsSize):
		var i = ti + basicCommandsSize
		send_message_without_event("%s%s" % [commandSign, commands[i].get_name()], true, false)
		send_message_without_event(": %s" % commands[i].get_description(), false, false)
		send_message_without_event(" (args: ", false, false)
		_print_args(i)
		send_message_without_event(")") # new line
	 
	
func send_message_without_event(message : String, clickable = false, newLine = true):
	if message.empty():
		return
	
	if clickable:
		textLabel.push_meta(message)
		textLabel.append_bbcode("[b][u]")
	
	messageHistory += message
	textLabel.add_text(message)
	if newLine:
		textLabel.newline()
	lineEdit.clear()
	
	if clickable:
		textLabel.pop()
		textLabel.pop()
		textLabel.pop()

# check first for real command
func get_command(cmdName : String) -> Command:
	var regex = RegEx.new()
	# if command looks like: "/..."
	regex.compile("^(\\S+)\\s?.*$")
	var result = regex.search(cmdName)
	
	if result:
		cmdName = result.get_string(1)
		for com in commands:
			if com.get_name() == cmdName:
				# commands[com] is the value
				return com
	return null

# before calling this method check for command sign
func is_input_real_command(cmdName : String) -> bool:
	if cmdName.empty():
		return false
		
	var regex = RegEx.new()
	regex.compile("^(\\S+).*$")
	var result = regex.search(cmdName)
	
	
	if result:
		cmdName = result.get_string(1)
		for com in commands:
			if com.get_name() == cmdName:
				# commands[com] is the value
				return true
	return false

func get_closest_commands(cmdName : String) -> Array:
	if cmdName.empty() or cmdName[0] != commandSign:
		return []
	
	var regex = RegEx.new()
	regex.compile("^%s(\\S+).*$" % commandSign)
	var result = regex.search(cmdName)

	var results = []

	if result:
		cmdName = result.get_string(1)
		for com in commands:
			if cmdName in com.get_name():	
				results.append(com.get_name())
		
		return results
		
	else:
		return []


func _extract_arguments(commandPostFix : String) -> Array:
	var args = commandPostFix.split(" ", false)
	args.remove(0)
	return args


func _on_send_pressed():
	if not lineEdit.text.empty():
		send_message(lineEdit.text + str("\n"))
	lineEdit.grab_focus()
	

func _on_richTextLabel_meta_clicked(meta):
	lineEdit.text = meta.substr(0, meta.length())
	lineEdit.set_cursor_position(lineEdit.get_text().length())
	lineEdit.grab_focus()


func _on_titleBar_gui_input(event):
	if enableWindowDrag:
		if event is InputEventMouseButton and event.button_index == BUTTON_LEFT: 
			if event.pressed and not event.is_echo():
				startWindowDragPos = get_global_mouse_position() - rect_global_position
				dragging = true
			elif not event.pressed and not event.is_echo():
				dragging = false
				rect_global_position = get_global_mouse_position() - startWindowDragPos
	

func _on_animation_animation_started():
	lineEdit.clear()
 

func _on_hideConsole_button_up():
	if Rect2($offset/hideConsole.rect_global_position, $offset/hideConsole.rect_size).has_point( \
			get_global_mouse_position()):
		toggle_console()


# Array printer
func _print_args(commandIndex : int):
	var i = commandIndex
	if commands[i].get_expected_args().size() > 1:
		send_message_without_event("", false, false)
		for arg in range(commands[i].get_expected_args().size()):
			send_message_without_event("%s" % commands[i].get_expected_args()[arg], false, false)
			if arg == commands[i].get_expected_args().size() - 2:
				send_message_without_event(" or " + \
						str(commands[i].get_expected_args()[arg+1]), false, false)
				break
			else:
				send_message_without_event(", ", false, false)
		send_message_without_event("", false, false)
	
	elif commands[i].get_expected_args().size() == 1: 
		send_message_without_event("1", false, false)
	
	else:
		send_message_without_event("0", false, false)


