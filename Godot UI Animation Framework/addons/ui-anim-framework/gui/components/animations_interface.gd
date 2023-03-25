@tool
extends UIAnimationInterface


# VARIABLES
## File Access
@onready var search_directory: DirAccess

# References
## Icons
@onready var folder_icon: CompressedTexture2D = preload("res://addons/ui-anim-framework/gui/icons/folder_icon.png")

## Children
@onready var file_explorer: Tree = $%FileExplorerTree
@onready var current_selected_label: Label = $%CurrentSelectedLabel

## Constants
const CHUNK_SIZE = 1024

## Internal Data
var anim_files_hash: HashingContext

### Animation Files
var anim_main_folders: PackedStringArray
var anim_sub_folders: PackedStringArray
var file_explorer_folders: Dictionary
var file_explorer_files: Dictionary
var anim_files: PackedStringArray

## Temp Values
var has_new_files: bool = true
var current_anim: String


# POPULATE UI
func _populate_interface() -> void:
	if not visible:
		return
	if has_new_files:
		_get_anim_files()
		_populate_file_explorer()
		has_new_files = false

func _check_default_folders() -> void:
	load_settings()
	var temp_main_folders: PackedStringArray
	temp_main_folders.append(settings.default_animation_folder)
	temp_main_folders.append_array(settings.animation_folders)
	if temp_main_folders == anim_main_folders:
		has_new_files = true

func _get_anim_files() -> void:
	anim_main_folders.clear()
	anim_sub_folders.clear()
	anim_files.clear()
	anim_main_folders.append(settings.default_animation_folder)
	anim_main_folders.append_array(settings.animation_folders)
	for path in anim_main_folders:
		_get_res_files_in_dir(path)

func _get_res_files_in_dir(directory_path: String):
	search_directory = DirAccess.open(directory_path)
	if not search_directory:
		return
	
	# Search for .res files in this directory
	var file_names: PackedStringArray = search_directory.get_files()
	for file_name in file_names:
		if file_name.get_extension() == "res":
			anim_files.append(directory_path + file_name)
		
	var folder_paths: PackedStringArray
	var folder_names: PackedStringArray = search_directory.get_directories()
	for folder_name in folder_names:
		folder_paths.append(directory_path + folder_name + "/")
	
	# If there are sub folders, search for files in those too
	if folder_paths.is_empty():
		return
	anim_sub_folders.append_array(folder_paths)
	for folder in folder_paths:
		_get_res_files_in_dir(folder)

func _populate_file_explorer() -> void:
	file_explorer.clear()
	file_explorer_folders.clear()
	file_explorer_files.clear()
	_populate_explorer_folders()
	_populate_explorer_files()

func _populate_explorer_folders() -> void:
	var root: TreeItem = file_explorer.create_item()
	file_explorer.hide_root = true
	
	for folder in anim_main_folders:
		file_explorer_folders[folder] = file_explorer.create_item(root)
		print(file_explorer_folders[folder])
		file_explorer_folders[folder].set_text(0, _get_folder_name(folder))
		file_explorer_folders[folder].set_icon(0, folder_icon)
	if anim_sub_folders.is_empty():
		return
	for folder in anim_sub_folders:
		var parent_folder: String = _get_parent_folder(folder)
		file_explorer_folders[folder] = file_explorer.create_item(file_explorer_folders[parent_folder])
		file_explorer_folders[folder].set_text(0, _get_folder_name(folder))
		file_explorer_folders[folder].set_icon(0, folder_icon)

func _populate_explorer_files() -> void:
	for file in anim_files: 
		var parent_folder: String = _get_parent_folder(file)
		file_explorer_files[file] = file_explorer.create_item(file_explorer_folders[parent_folder])
		print(file_explorer_files[file])
		file_explorer_files[file].set_text(0, _get_file_name(file))


# UI UPDATES
func _update_interface() -> void:
	_update_current_animation()

func _update_current_animation() -> void:
	if file_explorer.get_selected() == null:
		current_anim = ""
	else:
		var explorer_files: Array[TreeItem]
		explorer_files.append_array(file_explorer_files.values())
		var selected_item: TreeItem = file_explorer.get_selected()
		var selected_index: int = explorer_files.find(selected_item)
		if selected_index == -1:
			current_anim = ""
		else:
			current_anim = file_explorer_files.keys()[selected_index]
	
	if current_anim == "":
		current_selected_label.add_theme_color_override("font_color", Color.ORANGE)
		current_selected_label.text = "None"
	else:
		current_selected_label.add_theme_color_override("font_color", Color.GREEN)
		current_selected_label.text = _get_file_name(current_anim)


# File Explorer
func _get_parent_folder(path: String) -> String:
	if path.ends_with("/"):
		path = path.substr(0,path.length() - 1)
	return path.get_base_dir() + "/"

func _get_folder_name(path: String) -> String:
	path = path.substr(0, path.length() - 1)
	return path.get_file().capitalize()

func _get_file_name(path: String) -> String:
	return path.get_file().get_basename().capitalize()

# UI INTERACTION
func _on_file_explorer_tree_item_selected():
	update()
