extends Node

func _ready():
	create_save_directories()

func create_save_directories():
	var save_path = "user://saves/"
	if not DirAccess.dir_exists_absolute(save_path):
		DirAccess.make_dir_absolute(save_path)
		print("Created directory: %s" % save_path)

	var chunks_path = save_path + "chunks/"
	if not DirAccess.dir_exists_absolute(chunks_path):
		DirAccess.make_dir_absolute(chunks_path)
		print("Created directory: %s" % chunks_path)
