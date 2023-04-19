@tool
class_name UIAnimationStartup extends Node


# INITIALISATION
func _init():
	var editor_dir := DirAccess.open("res://")
	var settings: UIAnimationSettings = UIAnimationSettings.new()
	if editor_dir.file_exists(settings.save_path):
		_done()
		return
	
	ResourceSaver.save(settings, settings.save_path)
	_done()

func _done() -> void:
	queue_free()
