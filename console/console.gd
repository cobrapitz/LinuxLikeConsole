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

enum BBCode {
	BOLD = 1,
	ITALICS = 2,
	UNDERLINE = 4,
	CODE = 8,
	CENTER = 16,
	RIGHT = 32,
	FILL = 64,
	INDENT = 128,
	URL = 256
}

var _flags : String 
var _antiFlags : String # flagendings 

const COMMAND_NOT_FOUND_MSG := "[color=red]Command not found![/color]"


#var logFile = preload("res://Log.gd").new()

onready var lineEdit = $offset/lineEdit
onready var textLabel = $offset/richTextLabel
onready var animation = $offset/animation

var allText = ""
#var messageHistory := ""
var messages := []
var currentIndex := 0

var startWindowDragPos : Vector2
var dragging : bool
var mdefaultSize := Vector2(550.0, 275.0)

var commands := []
var basicCommandsSize := 0

const VARIADIC_COMMANDS = 65535 # amount of parameters


var isShown := true

var _ctrlPressed = false
var _setCaretPosToLast = false

const toggleConsole := KEY_QUOTELEFT


# export vars

export(String, "blue", "dark", "light", "gray", "ubuntu", "arch_aqua", "arch_green", "windows") var designSelector = "arch_green" setget update_theme
export(String, "top", "bottom", "left", "right", "full_screen", "custom") var dockingStation = "custom" setget update_docking
export(bool) var showButton = false setget update_visibility_button
export(bool) var showLine = false setget update_visibility_line
export(Color) var titleBarColor = Color(0, 0.18, 0.62, 0.95) setget update_tile_bar_color
export(bool) var roundedTitleBar = true setget update_corner 
export(Color) var backgroundColor = Color(0.09,0.09,0.16, 0.87) setget update_background_color
export(Color) var lineEditColor = Color() setget update_line_edit_color
export(Color) var buttonColor = Color(1.0, 1.0, 1.0, 1.0) setget update_button_color
export(String, "black", "white", "gray", "green", "red", "yellow", "blue", "aqua") var textColorSelector = Color.white setget update_text_color
export(bool) var enableWindowDrag = true 
export(bool) var logEnabled = false 
export(String) var userMessageSign = ">" setget update_lineEdit
export(String) var commandSign := "/"
export(bool) var addNewLineAfterCommand = false 
export(String) var next_message_history = "ui_down"
export(String) var previous_message_history = "ui_up"
export(String) var autoComplete = "ui_focus_next"

var textColor

var _customThemes : Dictionary = {
	"blue" : {
		"titleBarColor" : Color(0, 0.18, 0.62, 0.95),
		"backgroundColor" : Color(0.09, 0.09, 0.16, 0.87),
		"lineEditColor" : Color(0.21, 0.21, 0.21, 0.82),
		"textColor" : "white",
		"buttonColor" : Color(0.14, 0.14, 0.18, 0.34),
		"roundedTitleBar" : true
	}, 
	"dark": {
		"titleBarColor" : Color(0, 0, 0, 0.95),
		"backgroundColor" : Color(0.06, 0.06, 0.08, 0.88),
		"lineEditColor" : Color(0.21, 0.21, 0.21, 0.82),
		"textColor" : "white",
		"buttonColor" : Color(0.14, 0.14, 0.18, 0.34),
		"roundedTitleBar" : true
	},
	"light": {
		"titleBarColor" : Color(1.0, 1.0, 1.0, 0.95),
		"backgroundColor" : Color(1.0, 1.0, 1.0, 0.5),
		"lineEditColor" : Color(0.87, 0.87, 0.87, 0.71),
		"textColor" : "black",
		"buttonColor" : Color(0.14, 0.14, 0.18, 0.34),
		"roundedTitleBar" : true
	},
	"gray": {
		"titleBarColor" : Color(0.24, 0.24, 0.24, 0.95),
		"backgroundColor" : Color(0.03, 0.03, 0.03, 0.5),
		"lineEditColor" : Color(0.21, 0.21, 0.21, 0.82),
		"textColor" : "white",
		"buttonColor" : Color(0.14, 0.14, 0.18, 0.34),
		"roundedTitleBar" : true
	},
	"ubuntu": {
		"titleBarColor" : Color(0.3, 0.3, 0.3, 0.95),
		"backgroundColor" : Color(0.26, 0.0, 0.27, 0.9),
		"lineEditColor" : Color(0.13, 0.0, 0.18, 0.77),
		"textColor" : "white",
		"buttonColor" : Color(0.01, 0.01, 0.01, 0.34),
		"roundedTitleBar" : true
	},
	"arch_aqua": {
		"titleBarColor" : Color(0.35, 0.34, 0.34, 0.98),
		"backgroundColor" : Color(0.0, 0.25, 0.38, 0.87),
		"lineEditColor" : Color(0.21, 0.35, 0.66, 0.82),
		"textColor" : "aqua",
		"buttonColor" : Color(0.26, 0.27, 0.63, 0.34),
		"roundedTitleBar" : true
	},
	"arch_green": {
		"titleBarColor" : Color(0.30, 0.27, 0.27, 1.0),
		"backgroundColor" : Color(0.0, 0.0, 0.0, 0.98),
		"lineEditColor" : Color(0.24, 0.24, 0.24, 0.98),
		"textColor" : "green",
		"buttonColor" : Color(0.3, 0.3, 0.32, 0.34),
		"roundedTitleBar" : true
	},
	"windows": {
		"titleBarColor" : Color(1.0, 1.0, 1.0, 1.0),
		"backgroundColor" : Color(0.0, 0.0, 0.0, 1.0),
		"lineEditColor" : Color(0.11, 0.11,0.11, 0.82),
		"textColor" : "white",
		"buttonColor" : Color(0.22, 0.22, 0.22, 0.34),
		"roundedTitleBar" : false
	}
}

# export vars setget funcs

func update_docking(dock):
	if !is_inside_tree():
		return
	
	#if dock != "custom" and dockingStation == "custom":
	#	mdefaultSize = rect_size
	
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
			rect_size.y = mdefaultSize.y
			rect_size.x = rectSize.x
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
	if has_node("offset/richTextLabel") and $offset/richTextLabel != null and \
			has_node("offset/lineEdit") and $offset/lineEdit != null:
		if typeof(selected) == TYPE_COLOR:
			textColorSelector = "custom"
			textColor = selected
		else:
			textColorSelector = selected
	
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
				"aqua":
					textColor = Color.aqua
				_:
					return
		set_default_text_color(textColor)
				
				
func update_theme(selected):
	designSelector = selected
	
	if _customThemes.has(selected):
		var selectedTheme = _customThemes[selected]
		titleBarColor = selectedTheme["titleBarColor"]
		backgroundColor = selectedTheme["backgroundColor"]
		lineEditColor = selectedTheme["lineEditColor"]
		textColor = selectedTheme["textColor"]
		buttonColor = selectedTheme["buttonColor"]
		roundedTitleBar = selectedTheme["roundedTitleBar"]
		_update_theme_related_elements()
	else:
		print("no such theme " + str(selected))


func update_corner(rounded : bool):
	roundedTitleBar = rounded
	if has_node("offset/titleBarBackground") and $offset/titleBarBackground != null:
		var newStyle = $offset/titleBarBackground.theme.get("Panel/styles/panel")
		 
		if rounded:
			newStyle.set("corner_radius_top_left", 7)
			newStyle.set("corner_radius_top_right", 7)
		if not rounded:
			newStyle.set("corner_radius_top_left", 0)
			newStyle.set("corner_radius_top_right", 0)
		

func _update_theme_related_elements():
	update_text_color(textColor)
	update_tile_bar_color(titleBarColor)
	update_background_color(backgroundColor)
	update_line_edit_color(lineEditColor)
	update_button_color(buttonColor)
	update_corner(roundedTitleBar)
	property_list_changed_notify() # to see the changes in the editor
	
			
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
	
	
func add_basic_commands():
	DefaultCommands.new(self)


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
	
	if event is InputEventKey:
		if event.is_pressed() and not event.is_echo():
			if event.scancode == KEY_ENTER:
				if not lineEdit.text.empty():
					send_line()
			if event.scancode == KEY_ESCAPE:
				lineEdit.text = ""
			if event.scancode == KEY_CONTROL:
				_ctrlPressed = true		
			if event.scancode == KEY_LEFT and not _ctrlPressed and lineEdit.get_cursor_position() == 0:
				_setCaretPosToLast = true
		else:
			if event.scancode == KEY_CONTROL:
				_ctrlPressed = false
		
	if event.is_action_pressed(previous_message_history):
		if messages.empty():
			return
		currentIndex -= 1
		if currentIndex < 0:
			currentIndex = messages.size() - 1
		elif currentIndex > messages.size() - 1:
			currentIndex = 0
		lineEdit.text = messages[currentIndex]
		grab_line_focus()
		lineEdit.set_cursor_position(lineEdit.text.length())
		
	elif event.is_action_pressed(next_message_history):
		if messages.empty():
			return
		currentIndex += 1
		if currentIndex < 0:
			currentIndex = 0
		elif currentIndex > messages.size() - 1:
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
				new_line()
				append_message_no_event("possible commands: ")
				for c in closests:
					new_line()
					append_message_no_event(commandSign + c, true)
					messages.append(commandSign + c)
				#send_message_without_event("Press [Up] or [Down] to cycle through available commands.", false)
				lineEdit.text = tempLine
				lineEdit.set_cursor_position(lineEdit.text.length())



func _process(_delta):
	if dragging and enableWindowDrag:
		rect_global_position = get_global_mouse_position() - startWindowDragPos
	
	if _setCaretPosToLast:
		_setCaretPosToLast = false
		lineEdit.set_cursor_position(lineEdit.text.length())


func add_theme(themeName : String, \
			titleBarColor, backgroundColor, lineEditColor, textColor, buttonColor, roundedTitleBar : bool):
	
	_customThemes[themeName] = {
		"titleBarColor" : titleBarColor,
		"backgroundColor" : backgroundColor,
		"lineEditColor" : lineEditColor,
		"textColor" : textColor,
		"buttonColor" : buttonColor,
		"roundedTitleBar" : roundedTitleBar
	}
	


func set_default_text_color(color : Color):
	$offset/richTextLabel.set("custom_colors/default_color", color)
	$offset/lineEdit.set("custom_colors/font_color", color)
	

func toggle_console() -> void:
	if isShown:
		hide()
	else:
		show()
		animation.playback_speed = 1.0
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
	
	
func remove_command_by_name(commandName : String) -> bool:
	for i in range(commands.size()):
		if commands[i].get_name() == commandName:
			commands.remove(i)
			return true
	return false
	
	
func new_line():
	append_message_no_event("\n", false)
	
	
func clear_flags():
	_flags = ""
	_antiFlags = ""
	
	
func append_flags(flags : int):
	if (flags & BBCode.BOLD) == BBCode.BOLD:
		_flags += "[b]"
		_antiFlags = _antiFlags.insert(0, "[/b]")
	if (flags & BBCode.ITALICS) == BBCode.ITALICS:
		_flags += "[i]"
		_antiFlags = _antiFlags.insert(0, "[/i]")
	if (flags & BBCode.UNDERLINE) == BBCode.UNDERLINE:
		_flags += "[u]"
		_antiFlags = _antiFlags.insert(0, "[/u]")
	if (flags & BBCode.CODE) == BBCode.CODE:
		_flags += "[code]"
		_antiFlags = _antiFlags.insert(0, "[/code]")
	if (flags & BBCode.CENTER) == BBCode.CENTER:
		_flags += "[center]"
		_antiFlags = _antiFlags.insert(0, "[/center]")
	if (flags & BBCode.RIGHT) == BBCode.RIGHT:
		_flags += "[right]"
		_antiFlags = _antiFlags.insert(0, "[/right]")
	if (flags & BBCode.FILL) == BBCode.FILL:
		_flags += "[fill]"
		_antiFlags = _antiFlags.insert(0, "[/fill]")
	if (flags & BBCode.INDENT) == BBCode.INDENT:
		_flags += "[indent]"
		_antiFlags = _antiFlags.insert(0, "[/indent]")
	if (flags & BBCode.URL) == BBCode.URL:
		_flags += "[url]"
		_antiFlags = _antiFlags.insert(0, "[/url]")


func write(message : String, clickable = false, sendToConsole = true, flags = 0):
	append_message(message, clickable, sendToConsole, flags)
	
	
func writeLine(message : String, clickable = false, sendToConsole = true, flags = 0):
	append_message(message, clickable, sendToConsole, flags)
	new_line()
 

func append_message_no_event(message : String, clickableMeta = false, sendToConsole = true, flags = 0):
	if message.empty():
		return

	if _flags.empty(): # load flags if not passed
		append_flags(flags)
	
	if message.empty():
		return
	
	if clickableMeta:
		textLabel.push_meta(message) # meta click, writes meta to console
		
	if _flags.length() > 0:
		textLabel.append_bbcode(_flags) # bbcode
	
	
	if sendToConsole:
		textLabel.append_bbcode(message) # actual message
		if logEnabled:
			add_to_log(message)
	
	if clickableMeta:
		textLabel.pop()
		
	if _flags.length() > 0:
		textLabel.append_bbcode(_antiFlags)
		
	clear_flags()
	

func append_message(message : String, clickableMeta = false, sendToConsole = true, flags = 0): 
	if message.empty():
		return
	
	# let the message be switched through
	messages.append(message)
	currentIndex = -1
	
	append_message_no_event(message, clickableMeta, sendToConsole, flags)

	if message[0] == commandSign: # check if the input is a command
		execute_command(message)

	emit_signal("on_message_sent", lineEdit.text)	
	

func execute_command(message : String):
	var currentCommand = message
	currentCommand = currentCommand.trim_prefix(commandSign) # remove command sign
	if is_input_command(currentCommand):
		# return the command and the whole message
		var cmd = get_command(currentCommand)
		if cmd == null:
			new_line()
			append_message_no_event(COMMAND_NOT_FOUND_MSG)
			new_line()
			return
			
		var found = false
		for i in range(commands.size()):
			if commands[i].get_name() == cmd.get_name(): # found command
				found = true
				var args = _extract_arguments(currentCommand)
				if cmd.get_ref().get_expected_arguments().size() == 1 and \
						cmd.get_ref().get_expected_arguments()[0] == VARIADIC_COMMANDS: # custom amount of arguments
					cmd.apply(args)
					emit_signal("on_command_sent", cmd, currentCommand)
					break
					
				if not args.size() in cmd.get_ref().get_expected_arguments():
					new_line()
					append_message_no_event("expected: ")
					_print_args(i)
					append_message_no_event(" arguments!")
					
					if addNewLineAfterCommand:
						new_line()
				else:
					cmd.apply(_extract_arguments(currentCommand))
					
				emit_signal("on_command_sent", cmd, currentCommand)
				break
		if not found:
			new_line()
			append_message_no_event(COMMAND_NOT_FOUND_MSG)
			new_line()
	else:
		new_line()
		append_message_no_event(COMMAND_NOT_FOUND_MSG)
		new_line()


# check first for real command
func get_command(command : String) -> Command:
	var cmdName = command.split(" ", false)[0] 
	
	for com in commands:
		if com.get_name() == cmdName:
			return com
	return null # if not found


func copy_command(command : Command) -> Command:
	var newCommand = Command.new(command.get_name(), command.get_ref(), command.get_args(), command.get_description())
	return newCommand

	
# before calling this method check for command sign
func is_input_command(message : String) -> bool:
	if message.empty():
		return false
		
	var cmdName : String = message.split(" ", false)[0]
	cmdName = cmdName.trim_prefix(commandSign)
	
	for com in commands:
		if com.get_name() == cmdName:
			return true
	return false
	

func get_closest_commands(command : String) -> Array:
	if command.empty() or command[0] != commandSign:
		return []
	
	var results = []
	var cmdName : String = command.split(" ", false)[0]
	cmdName = cmdName.trim_prefix(commandSign)
		
	for com in commands:
		if com.get_name().length() < cmdName.length():
			continue
		var addToResults = true
		for i in range(cmdName.length()):
			if not cmdName[i].to_lower() == com.get_name()[i].to_lower():
				addToResults = false
				break
				
		if addToResults:
			results.append(com.get_name())
				
	return results


func _extract_arguments(commandPostFix : String) -> Array:
	var args = commandPostFix.split(" ", false)
	args.remove(0)
	return args


func _on_send_pressed():
	if not lineEdit.text.empty():
		send_line()
	lineEdit.grab_focus()
	

func send_line():
	append_message(lineEdit.text)
	lineEdit.text = ""
	new_line()
	

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


func _on_console_resized():
	if dockingStation != "custom":
		match (dockingStation):
			"top":
				mdefaultSize.y = rect_size.y
			"left":
				mdefaultSize.x = rect_size.x
			"right":
				mdefaultSize.x = rect_size.x
			"bottom":
				mdefaultSize.y = rect_size.y
			"full_screen":
				return
			_:
				print("not registered docking: " + dockingStation)
	
		

func add_to_log(message : String):
	allText += message
	var dir = Directory.new()
	if not dir.dir_exists("res://logs"):
		dir.make_dir("res://logs")
	var file = File.new()
	file.open("res://logs/consolelog.txt", file.READ_WRITE)
	file.seek_end()
	file.store_string(message)
	file.close()


func save_log_to_file(path : String):
	var fileName = path
	
	var dir = Directory.new()
	if not dir.dir_exists(fileName):
		print("dir does not exists to save log file!")
	var file = File.new()
	file.open(fileName, file.WRITE_READ)
	file.store_string(allText)
	file.close()
	

# Array printer
func _print_args(commandIndex : int):
	var i = commandIndex
	if commands[i].get_expected_args().size() > 1:
		for arg in range(commands[i].get_expected_args().size()):
			if (commands[i].get_expected_args()[arg] == VARIADIC_COMMANDS):
				append_message_no_event("variadic")
			else:
				append_message_no_event(str(commands[i].get_expected_args()[arg]))
			if arg == commands[i].get_expected_args().size() - 2:
				append_message_no_event(" or ")
				if (commands[i].get_expected_args()[arg+1] == VARIADIC_COMMANDS):
					append_message_no_event("variadic")
				else:
					append_message_no_event(str(commands[i].get_expected_args()[arg+1]))
				break
			else:
				append_message_no_event(", ")
	
	elif commands[i].get_expected_args().size() == 1: 
		if commands[i].get_expected_args()[0] == VARIADIC_COMMANDS:
			append_message_no_event("variadic")
		else:
			append_message_no_event("1")
	else:
		append_message_no_event("0")