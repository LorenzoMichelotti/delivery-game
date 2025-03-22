extends Node

static func save_resource(data, save_path):
	ResourceSaver.save(data, save_path)
	return

static func load_resource(save_path):
	print(save_path)
	if ResourceLoader.exists(save_path):
		return load(save_path)
	return null

func save_all():
	print("saving all persistent nodes...")
	var save_nodes = get_tree().get_nodes_in_group("persist")
	for node in save_nodes:
		if node.save_path.is_empty():
			print("persistent node '%s' has no save path, skipped" % node.name)
			continue
		if !node.has_method("save_data"):
			print("persistent node '%s' is missing a save_data() function, skipped" % node.name)
			continue
		var node_data = node.call("save_data")

func load_all():
	print("loading all persistent nodes...")
	var save_nodes = get_tree().get_nodes_in_group("persist")
	for node in save_nodes:
		if node.save_path.is_empty():
			print("persistent node '%s' has no save path, skipped" % node.name)
			continue
		if !node.has_method("load_data"):
			print("persistent node '%s' is missing a load_data() function, skipped" % node.name)
			continue
		var node_data = node.call("load_data")

func _ready():
	get_tree().set_auto_accept_quit(false)
	load_all()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("received close request")
		save_all()
		get_tree().quit() # default behavior
