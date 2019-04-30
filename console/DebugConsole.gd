extends CanvasLayer

func write_line(msg, addToLog = true, userPrefix = false, messageSignPrefix = false,  clickableMeta = false, sendToConsole = true, flags = 0):
	$console.write_line(str(msg), addToLog, userPrefix, messageSignPrefix, clickableMeta, sendToConsole, flags)

func send(msg, addToLog = true, userPrefix = false, messageSignPrefix = false,  clickableMeta = false, sendToConsole = true, flags = 0):
	write_line(msg, addToLog, userPrefix, messageSignPrefix, clickableMeta, sendToConsole, flags)
	
func append_message(msg, addToLog = true, userPrefix = false, messageSignPrefix = false,  clickableMeta = false, sendToConsole = true, flags = 0):
	write_line(msg, addToLog, userPrefix, messageSignPrefix, clickableMeta, sendToConsole, flags)

func error(msg, addToLog = true):
	$console.error(msg, addToLog)

func warn(msg, addToLog = true):
	$console.warn(msg, addToLog)

func success(msg, addToLog = true):
	$console.success(msg, addToLog)

func add_command(command):
	$console.add_command(command)