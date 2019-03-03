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

const DefaultCommands = preload("res://console/default_commands.gd")

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
var mdefaultSize := Vector2(800.0, 425.0)

var commands := []
var basicCommandsSize := 0


var isShown := true

const toggleConsole = KEY_QUOTELEFT

# export vars

export(String, "top", "bottom", "left", "right", "full_screen", "custom") var dockingStation = "custom" setget update_docking
export(String, "blue", "dark", "light", "gray") var designSelector setget update_theme
export(Color) var titleBarColor = Color(0, 0.18, 0.62, 0.95) setget update_tile_bar_color
export(Color) var backgroundColor = Color(0.09,0.09,0.16, 0.87) setget update_background_color
export(Color) var lineEditColor = Color() setget update_line_edit_color
export(Color) var buttonColor = Color(1.0, 1.0, 1.0, 1.0) setget update_button_color
export(String, "black", "white", "gray", "green", "red", "yellow", "blue") var textColorSelector = Color.white setget update_text_color
export(bool) var showButton = false setget update_visibility_button
export(bool) var showLine = false setget update_visibility_line
export(bool) var enableWindowDrag = true 
export(String) var userMessageSign = ">" setget update_lineEdit
export(String) var commandSign := "/"
export(bool) var addNewLineAfterCommand = false 
export(String) var next_message_history = "ui_down"
export(String) var previous_message_history = "ui_up"
export(String) var autoComplete = "ui_focus_next"

var textColor

# export vars setget funcs

func update_docking(dock):
	if !is_inside_tree():
		return
	
	if dock != "custom" and dockingStation == "custom":
		mdefaultSize = rect_size
	
	dockingStation = dock
	
	var rectSize : Vector2
	rectSize = get_viewport_rect().size
	
	match (dockingStation):
		"top":
			rect_position = Vector2(0.0, 0.0)
			rect_size.x = rectSize.x
			rect_size.y = mdefaultSize.y
		"bottom":
			rect_position = Vector2(0.0, rectSize.y - mdefaultSize.y)
			rect_size.x = rectSize.x
			rect_size.y = mdefaultSize.y
		"left":
			rect_position = Vector2(0.0, 0.0)
			rect_size.x = rectSize.x * 0.5
			rect_size.y = rectSize.y
		"right":
			rect_position = Vector2(rectSize.x * 0.5,  0.0)
			rect_size.x = rectSize.x * 0.5
			rect_size.y = rectSize.y
		"full_screen":
			rect_position = Vector2(0.0, 0.0)
			rect_size = rectSize
		"custom":
			rect_size = mdefaultSize
			return
		_:
			return

		
			
			
func update_button_color(color):
	buttonColor = color
	
	if has_node("offset/send") and $offset/send != null:
		var newStyle = $offset/send.theme.get("Button/styles/normal")
		newStyle.bg_color = buttonColor
		$offset/send.theme.set("Button/styles/normal", newStyle)


func update_line_edit_color(color):
	lineEditColor = color
	
	if has_node("offset/lineEditBackground") and $offset/lineEditBackground != null:
		$offset/lineEditBackground.color = color
		

func update_text_color(selected):
	textColorSelector = selected
	
	if has_node("offset/richTextLabel") and $offset/richTextLabel != null and \
			has_node("offset/lineEdit") and $offset/lineEdit != null:
		match (selected):
			"black":
				textColor = Color.black
			"white":
				textColor = Color.white
			"gray":
				textColor = Color.gray
			"green":
				textColor = Color.green
			"red":
				textColor = Color.red
			"yellow":
				textColor = Color.yellow
			"blue":
				textColor = Color.blue
			_:
				print("no such font " + str(selected))
				return
		$offset/richTextLabel.set("custom_colors/default_color", textColor)
		$offset/lineEdit.set("custom_colors/font_color", textColor)
		
				
				
func update_theme(selected):
	designSelector = selected
	match (selected):
		"blue":
			titleBarColor = Color(0, 0.18, 0.62, 0.95)
			backgroundColor = Color(0.09, 0.09, 0.16, 0.87)
			lineEditColor = Color(0.21, 0.21, 0.21, 0.82)
			textColor = "white"
			buttonColor = Color(0.14, 0.14, 0.18, 0.34)
		"dark":
			titleBarColor = Color(0, 0, 0, 0.95)
			backgroundColor = Color(0.06, 0.06, 0.08, 0.88)
			lineEditColor = Color(0.21, 0.21, 0.21, 0.82)
			textColor = "white"
			buttonColor = Color(0.14, 0.14, 0.18, 0.34)
		"light":
			titleBarColor = Color(1.0, 1.0, 1.0, 0.95)
			backgroundColor = Color(1.0, 1.0, 1.0, 0.5)
			lineEditColor = Color(0.87, 0.87, 0.87, 0.71)
			textColor = "black"
			buttonColor = Color(0.14, 0.14, 0.18, 0.34)
		"gray":
			titleBarColor = Color(0.24, 0.24, 0.24, 0.95)
			backgroundColor = Color(0.03, 0.03, 0.03, 0.5)
			lineEditColor = Color(0.21, 0.21, 0.21, 0.82)
			textColor = "white"
			buttonColor = Color(0.14, 0.14, 0.18, 0.34)
		_:
			print("no such theme " + str(selected))
			return
	_update_theme_related_elements()


func _update_theme_related_elements():
	update_text_color(textColor)
	update_tile_bar_color(titleBarColor)
	update_background_color(backgroundColor)
	update_line_edit_color(lineEditColor)
	update_button_color(buttonColor)
	property_list_changed_notify()
	
			
func update_tile_bar_color(color):
	titleBarColor = color
	if has_node("offset/titleBarBackground") and $offset/titleBarBackground != null:
		var newStyle = $offset/titleBarBackground.theme.get("Panel/styles/panel")
		#$offset/titleBarBackground.color = color
		newStyle.bg_color = color
		
		
func update_background_color(color):
	backgroundColor = color
	if has_node("offset/textBackground") and $offset/textBackground != null:
		$offset/textBackground.color = color
	if has_node("offset/buttonBackground") and $offset/buttonBackground != null:
		$offset/buttonBackground.color = color


func update_lineEdit(text : String):
	userMessageSign = text
	if has_node("offset/lineEdit") and $offset/lineEdit != null:
		$offset/lineEdit.set_placeholder(text)
		

func update_visibility_button(show):
	showButton = show
	if has_node("offset/send") and $offset/send != null:
		$offset/send.set_visible(show)
	if has_node("offset/sendText") and $offset/send != null:	
		$offset/sendText.set_visible(show)
	if has_node("offset/buttonBackground") and $offset/send != null:
		$offset/buttonBackground.set_visible(show)
		
	if has_node("offset/lineEdit") and $offset/lineEdit != null:
		if show:
			$offset/lineEdit.margin_right = -66
		else:
			$offset/lineEdit.margin_right = -5
			
	if has_node("offset/lineEditBackground") and $offset/lineEditBackground != null:
		if show:
			$offset/lineEditBackground.margin_right = -54
		else:
			$offset/lineEditBackground.margin_right = 0
			
			
func update_visibility_line(show):
	showLine = show
	if has_node("offset/textBackground") and $offset/textBackground != null:
		if show:
			$offset/textBackground.margin_bottom = -19
		else:
			$offset/textBackground.margin_bottom = 0
	
	if has_node("offset/lineEditBackground") and $offset/lineEditBackground != null:
		$offset/lineEditBackground.set_visible(show)

			

func _init():
	set_process_input(true)
	
	add_basic_commands()
	basicCommandsSize = commands.size()
	
	update_docking(dockingStation)
	
	
func add_basic_commands():
	var defaultCommands = DefaultCommands.new(self) 


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
	
	
func send_msg(msg : String):
	if msg.empty():
		return
	
	if not resetSwitch:
		messages.pop_back()
	resetSwitch = true
	
	# let the message be switched through
	messages.append(msg)
	currentIndex += 1
	messageHistory += msg
	
	
	

	
	
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
			if cmdName.to_lower() in com.get_name().lower():	
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


