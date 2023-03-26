@tool
extends UIAnimationInterface


signal populated


# VARIABLES
## File Access
@onready var search_directory: DirAccess

## References
var animation_creator: UIAnimationInterface
### Icons
@onready var folder_icon: CompressedTexture2D = preload("res://addons/ui-anim-framework/gui/icons/folder_icon.png")

## Children
@onready var file_explorer: Tree = $%FileExplorerTree
@onready var file_add_button: Button = $%FileAddButton
@onready var file_add_folder_button: Button = $%FileAddFolderButton
@onready var file_rename_button: Button = $%FileRenameButton
@onready var file_delete_button: Button = $%FileDeleteButton

## Constants
enum FILE_TYPES {
	DEFAULT_FILE,
	MAIN_FOLDER,
	FOLDER,
	ANIM_FILE
}

## Internal Data
### Animation Files
var file_explorer_default_files: Array[TreeItem]
var anim_main_folders: PackedStringArray
var anim_sub_folders: PackedStringArray
var anim_files: PackedStringArray
var file_explorer_folders: Dictionary
var file_explorer_files: Dictionary

### Temp Values
var has_new_files: bool = true
var populating: bool = false
var selected_file: TreeItem
var selected_file_type: int
var selected_anim: String = ""
var selected_anim_name: String = ""


# POPULATE UI
func _populate_interface() -> void:
	if not visible:
		return
	_check_default_folders()
	if has_new_files:
		populating = true
		_get_anim_files()
		await get_tree().create_timer(0.01).timeout
		_populate_file_explorer()
		has_new_files = false
		await populated
		populating = false

func _check_default_folders() -> void:
	load_settings()
	var temp_main_folders: PackedStringArray
	temp_main_folders.append(settings.default_animation_folder)
	temp_main_folders.append_array(settings.animation_folders)
	if temp_main_folders != anim_main_folders:
		has_new_files = true

## Read Directories
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

## Add Files to File Explorer
func _populate_file_explorer() -> void:
	file_explorer.deselect_all()
	file_explorer.clear()
	file_explorer_folders.clear()
	file_explorer_files.clear()
	_populate_explorer()

func _populate_explorer() -> void:
	# Starts with the folders
	var root: TreeItem = file_explorer.create_item()
	file_explorer.hide_root = true
	
	var selected_first: bool = false
	for folder in anim_main_folders:
		var folder_item: TreeItem = file_explorer.create_item(root)
		if not selected_first:
			selected_file = folder_item
			selected_file_type = FILE_TYPES.DEFAULT_FILE
			file_explorer_default_files.append(selected_file)
			selected_first = true
		file_explorer_folders[folder] = folder_item
		folder_item.set_text(0, _get_folder_name(folder))
		folder_item.set_icon(0, folder_icon)
	if not anim_sub_folders.is_empty():
		for folder in anim_sub_folders:
			var parent_folder: String = _get_parent_folder(folder)
			var folder_item: TreeItem = file_explorer.create_item(file_explorer_folders[parent_folder])
			if settings.default_animation_folder in folder:
				file_explorer_default_files.append(folder_item)
			file_explorer_folders[folder] = folder_item
			folder_item.set_text(0, _get_folder_name(folder))
			folder_item.set_icon(0, folder_icon)
	
	# Ends with the files
	_populate_explorer_files()

func _populate_explorer_files() -> void:
	for file in anim_files:
		var file_data = ResourceLoader.load(file)
		if "is_anim_file" in file_data:
			var parent_folder: String = _get_parent_folder(file)
			var file_item: TreeItem = file_explorer.create_item(file_explorer_folders[parent_folder])
			if settings.default_animation_folder in file:
				file_explorer_default_files.append(file_item)
			file_explorer_files[file] = file_item
			file_item.set_text(0, _get_file_name(file))
	
	file_explorer.set_selected(selected_file, 0)
	populated.emit()


# UI UPDATES
func _update_interface() -> void:
	if populating:
		await populated
	_update_selected_file()
	_update_explorer_tools()
	_update_selected_animation()
	animation_creator.update()

func _update_selected_file() -> void:
	selected_file = file_explorer.get_selected()
	# Check file type
	# Defaults
	if selected_file in file_explorer_default_files:
		selected_file_type = FILE_TYPES.DEFAULT_FILE
	## Folders
	var explorer_items_folders: Array[TreeItem]
	explorer_items_folders.append_array(file_explorer_folders.values())
	if selected_file in explorer_items_folders:
		var selected_index: int = explorer_items_folders.find(selected_file)
		var path: String = file_explorer_files.keys()[selected_index]
		if path in anim_main_folders:
			selected_file_type = FILE_TYPES.MAIN_FOLDER
		else:
			selected_file_type = FILE_TYPES.FOLDER
	else:
		selected_file_type = FILE_TYPES.ANIM_FILE

func _update_explorer_tools() -> void:
	file_add_button.disabled = true
	file_add_folder_button.disabled = true
	file_rename_button.disabled = true
	file_delete_button.disabled = true
	if selected_file_type == FILE_TYPES.DEFAULT_FILE:
		return
	file_add_button.disabled = false
	file_add_folder_button.disabled = false
	if selected_file_type == FILE_TYPES.MAIN_FOLDER:
		return
	file_rename_button.disabled = false
	file_delete_button.disabled = false

func _update_selected_animation() -> void:
	if file_explorer.get_selected() == null:
		return
	if not selected_file_type == FILE_TYPES.ANIM_FILE:
		return
	
	var explorer_items_files: Array[TreeItem]
	explorer_items_files.append_array(file_explorer_files.values())
	var selected_index: int = explorer_items_files.find(selected_file)
	selected_anim = file_explorer_files.keys()[selected_index]
	selected_anim_name = _get_file_name(selected_anim)


# PATH STRINGS
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
