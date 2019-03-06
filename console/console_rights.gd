class_name ClassRight

# The higher the number, the higher the privilegs
enum CallRights {
	USER = 1,
	TESTER = 2,
	MODERATOR = 3,
	ADMIN = 4,
	DEV = 65535
}

const _CallRights = {
	CallRights.USER : "user",
	CallRights.TESTER : "tester",
	CallRights.MODERATOR : "moderator",
	CallRights.ADMIN : "admin",
	CallRights.DEV : "dev"
}

var _rights = -1


func are_rights_sufficient(rights) -> bool:
	if _rights > rights:
		return false
	return true

# enum CallRights
func set_rights(rights):
	_rights = rights


func get_rights():
	return _rights
	

static func get_rights_name(right : int):
	if _CallRights.has(right):
		return _CallRights[right]
	else:
		print("couldn't find rights id")
		return -1

# get_rights_by_name("admin")
static func get_rights_by_name(rightsName : String):
	for i in range(_CallRights.size()):
		if _CallRights.values()[i] == rightsName:
			return _CallRights.keys()[i]
	print("couldn't find rights by name")
	
	
	
	
	
	
	
	