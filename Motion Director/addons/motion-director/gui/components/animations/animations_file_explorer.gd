@tool
extends MotionDirectorInterface


# VARIABLES
## File Access
@onready var file_access_directory: DirAccess

## References
var motion_creator: MotionDirectorInterface
### Icons
@onready var folder_icon: CompressedTexture2D = preload("res://addons/motion-director/gui/icons/tools/folder_icon.png")

## Children
@onready var file_explorer: Tree = $%FileExplorerTree
@onready var file_return_to_button: Button = $%FileReturnToButton
@onready var file_add_button: Button = $%FileAddButton
@onready var file_add_folder_button: Button = $%FileAddFolderButton
@onready var file_copy_cut_buttons: MarginContainer = $%FileCopyCutButtons
@onready var file_copy_button: Button = $%FileCopyButton
@onready var file_cut_button: Button = $%FileCutButton
@onready var file_paste_cancel_buttons: MarginContainer = $%FilePasteCancelButtons
@onready var file_paste_button: Button = $%FilePasteButton
@onready var file_cancel_button: Button = $%FileCancelButton
@onready var file_rename_button: Button = $%FileRenameButton
@onready var file_delete_button: Button = $%FileDeleteButton

## Constants
enum FILE_TYPES {
	DEFAULT_FILE,
	MAIN_FOLDER,
	FOLDER,
	MOTION_FILE
}
const ccp_button_groups: PackedStringArray = [
	"file_copy_cut_buttons",
	"file_paste_cancel_buttons"
]

## Internal Data
### Motion Files
var file_explorer_default_files: Array[TreeItem]
var motion_main_folders: PackedStringArray
var motion_sub_folders: PackedStringArray
var motion_files: PackedStringArray
var file_explorer_all_files: Dictionary
var file_explorer_folders: Dictionary
var file_explorer_files: Dictionary

### Temp Values
#### Status
var has_new_files: bool = true
#### Information
var selected_treefile: TreeItem
var selected_treefile_type: int
var selected_motion_path: String = ""
var selected_motion_name: String = ""
#### Modifying Files
var creation_folder: String
var copy_path: String
var copy_item: TreeItem
var copy_item_name: String
var copy_item_type: int # 0 = Folder, 1 = File
var copy_parent_item: TreeItem
var paste_path: String
var paste_path_type: int # 0 = Folder, 1 = File
var is_moving_file: bool = false


# POPULATE UI
func _populate_interface() -> void:
	if not visible:
		return
	_check_default_folders()
	if has_new_files:
		populating = true
		_get_motion_files()
		await get_tree().create_timer(0.01).timeout
		_populate_file_explorer()
		has_new_files = false
		await populated
		populating = false

func _check_default_folders() -> void:
	load_settings()
	var temp_main_folders: PackedStringArray
	temp_main_folders.append(settings.default_motion_folder)
	temp_main_folders.append_array(settings.motion_folders)
	if temp_main_folders != motion_main_folders:
		has_new_files = true

## Read Directories
func _get_motion_files() -> void:
	motion_main_folders.clear()
	motion_sub_folders.clear()
	motion_files.clear()
	motion_main_folders.append(settings.default_motion_folder)
	motion_main_folders.append_array(settings.motion_folders)
	for path in motion_main_folders:
		_get_res_files_in_dir(path)

func _get_res_files_in_dir(directory_path: String):
	file_access_directory = DirAccess.open(directory_path)
	if not file_access_directory:
		return
	
	# Search for .res files in this directory
	var file_names: PackedStringArray = file_access_directory.get_files()
	for file_name in file_names:
		if file_name.get_extension() == "res":
			motion_files.append(directory_path + file_name)
		
	var folder_paths: PackedStringArray
	var folder_names: PackedStringArray = file_access_directory.get_directories()
	for folder_name in folder_names:
		folder_paths.append(directory_path + folder_name + "/")
	
	# If there are sub folders, search for files in those too
	if folder_paths.is_empty():
		return
	motion_sub_folders.append_array(folder_paths)
	for folder in folder_paths:
		_get_res_files_in_dir(folder)

## Add Files to File Explorer
func _populate_file_explorer() -> void:
	file_explorer.deselect_all()
	file_explorer.clear()
	file_explorer_folders.clear()
	file_explorer_files.clear()
	file_explorer_all_files.clear()
	_populate_explorer()

func _populate_explorer() -> void:
	# Starts with the folders
	var root: TreeItem = file_explorer.create_item()
	file_explorer.hide_root = true
	
	var selected_first: bool = false
	for folder in motion_main_folders:
		var folder_item: TreeItem = file_explorer.create_item(root)
		if not selected_first:
			selected_treefile = folder_item
			selected_treefile_type = FILE_TYPES.DEFAULT_FILE
			file_explorer_default_files.append(selected_treefile)
			selected_first = true
		file_explorer_folders[folder] = folder_item
		folder_item.set_text(0, _get_folder_name(folder))
		folder_item.set_icon(0, folder_icon)
	if not motion_sub_folders.is_empty():
		for folder in motion_sub_folders:
			var parent_folder: String = _get_parent_folder(folder)
			var folder_item: TreeItem = file_explorer.create_item(file_explorer_folders[parent_folder])
			if settings.default_motion_folder in folder:
				file_explorer_default_files.append(folder_item)
			file_explorer_folders[folder] = folder_item
			folder_item.set_text(0, _get_folder_name(folder))
			folder_item.set_icon(0, folder_icon)
	
	# Ends with the files
	_populate_explorer_files()

func _populate_explorer_files() -> void:
	for file in motion_files:
		var file_data = ResourceLoader.load(file)
		if "is_motion_file" in file_data:
			var parent_folder: String = _get_parent_folder(file)
			var file_item: TreeItem = file_explorer.create_item(file_explorer_folders[parent_folder])
			if settings.default_motion_folder in file:
				file_explorer_default_files.append(file_item)
			file_explorer_files[file] = file_item
			file_item.set_text(0, _get_file_name(file))
	
	file_explorer_all_files.merge(file_explorer_folders)
	file_explorer_all_files.merge(file_explorer_files)
	file_explorer.deselect_all()
	file_explorer.set_selected(selected_treefile, 0)
	_explorer_collapse_all()
	populated.emit()


# UI UPDATES
func _update_interface() -> void:
	if populating:
		await populated
	_update_selected_file()
	_update_selected_motion()
	_update_explorer_tools()
	motion_creator.update()

func _update_selected_file() -> void:
	selected_treefile = file_explorer.get_selected()
	# Check file type
	# Defaults
	if selected_treefile in file_explorer_default_files:
		selected_treefile_type = FILE_TYPES.DEFAULT_FILE
		return
	
	var explorer_folder_items: Array[TreeItem]
	explorer_folder_items.append_array(file_explorer_folders.values())
	if not selected_treefile in explorer_folder_items:
		selected_treefile_type = FILE_TYPES.MOTION_FILE
		return
	
	var path: String = file_explorer_folders.find_key(selected_treefile)
	if path in motion_main_folders:
		selected_treefile_type = FILE_TYPES.MAIN_FOLDER
	else:
		selected_treefile_type = FILE_TYPES.FOLDER

func _update_selected_motion() -> void:
	if file_explorer.get_selected() == null:
		selected_motion_path = ""
		return
	if selected_treefile_type != FILE_TYPES.DEFAULT_FILE and selected_treefile_type != FILE_TYPES.MOTION_FILE:
		return
	if selected_treefile in file_explorer_folders.values():
		return
	var current_selection_path: String = file_explorer_files.find_key(selected_treefile)
	if selected_motion_path == current_selection_path:
		return
	
	selected_motion_path = current_selection_path
	selected_motion_name = _get_file_name(selected_motion_path)
	motion_creator.update()

func _update_explorer_tools() -> void:
	file_return_to_button.disabled = false
	if selected_motion_path == "" or selected_treefile == file_explorer_files[selected_motion_path]:
		file_return_to_button.disabled = true
	file_add_button.disabled = true
	file_add_folder_button.disabled = true
	file_copy_button.disabled = true
	file_cut_button.disabled = true
	file_paste_button.disabled = true
	file_rename_button.disabled = true
	file_delete_button.disabled = true
	if selected_treefile_type == FILE_TYPES.DEFAULT_FILE:
		return
	file_add_button.disabled = false
	file_add_folder_button.disabled = false
	if _can_paste():
		file_paste_button.disabled = false
	if selected_treefile_type == FILE_TYPES.MAIN_FOLDER:
		return
	file_cut_button.disabled = false
	file_rename_button.disabled = false
	file_delete_button.disabled = false
	if selected_treefile_type == FILE_TYPES.FOLDER:
		return
	file_copy_button.disabled = false

func _can_paste() -> bool:
	if selected_treefile == copy_parent_item:
		return false
	if selected_treefile == copy_item:
		if copy_item_type == 1:
			return false
	if selected_treefile.get_parent() == copy_parent_item:
		if selected_treefile_type == FILE_TYPES.MOTION_FILE:
			return false
	return true

# EXPLORER OVERIDES
func _return_to_selected_item() -> void:
	await get_tree().create_timer(0.01).timeout
	var selection_item: TreeItem
	if selected_motion_path != "":
		selection_item = file_explorer_files[selected_motion_path]
	file_explorer.deselect_all()
	_explorer_expand_from(selection_item)
	file_explorer.set_selected(selection_item, 0)

func _explorer_select_folder(path: String) -> void:
	await get_tree().create_timer(0.01).timeout
	var selection_item: TreeItem = file_explorer_folders[path]
	file_explorer.deselect_all()
	_explorer_expand_from(selection_item)
	file_explorer.set_selected(selection_item, 0)

func _explorer_collapse_all() -> void:
	for folder_item in file_explorer_folders.values():
		folder_item.collapsed = true

func _explorer_expand_all() -> void:
	file_explorer.get_root().set_collapsed_recursive(false)

func _explorer_expand_from(item: TreeItem) -> void:
	item.collapsed = false
	var item_path: String = file_explorer_all_files.find_key(item)
	var parent_path: String = _get_parent_folder(item_path)
	while motion_main_folders.find(parent_path) == -1:
		file_explorer_folders[parent_path].collapsed = false
		parent_path = _get_parent_folder(parent_path)
	file_explorer_folders[parent_path].collapsed = false


# PATH STRINGS
func _get_parent_folder(path: String) -> String:
	if path.ends_with("/"):
		path = path.substr(0,path.length() - 1)
	path = path.get_base_dir()
	if path == "res://":
		return path
	else:
		return path + "/"

func _get_folder_name(path: String) -> String:
	path = path.substr(0, path.length() - 1)
	return path.get_file().capitalize()

func _get_file_name(path: String) -> String:
	return path.get_file().get_basename().capitalize()

func _get_children_paths(parent_path: String) -> PackedStringArray:
	var paths: PackedStringArray
	var all_paths: PackedStringArray
	all_paths.append_array(file_explorer_files.keys())
	all_paths.append_array(file_explorer_folders.keys())
	for path in all_paths:
		if _get_parent_folder(path) == parent_path:
			paths.append(path)
	return paths

func _get_children_folder_names(parent_path: String) -> PackedStringArray:
	var names: PackedStringArray
	var paths: PackedStringArray = _get_children_paths(parent_path)
	for path in paths:
		if path.ends_with(".res"):
			continue
		names.append(_get_folder_name(path))
	return names

func _get_children_file_names(parent_path: String) -> PackedStringArray:
	var names: PackedStringArray
	var paths: PackedStringArray = _get_children_paths(parent_path)
	for path in paths:
		if path.ends_with("/"):
			continue
		names.append(_get_file_name(path))
	return names

func _get_sibling_names(path: String, type: int = 0) -> PackedStringArray:
	# type: 0 = Auto Detect, 1 = Folders, 2 = Files, 3 = All
	var names: PackedStringArray
	var parent: String = _get_parent_folder(path)
	match type:
		0:
			if path.ends_with("/"):
				names = _get_children_folder_names(parent)
			else:
				names = _get_children_file_names(parent)
			return names
		1:
			names = _get_children_folder_names(parent)
		2:
			names = _get_children_file_names(parent)
		3:
			names = _get_children_folder_names(parent)
			names.append_array(_get_children_file_names(parent))
	return names



# FILE MANAGEMENT
func _new_files() -> void:	
	has_new_files = true
	main_panel._refresh_files()
	update()

func _assign_creation_folder() -> void:
	if selected_treefile_type == FILE_TYPES.MOTION_FILE:
		creation_folder = _get_parent_folder(selected_motion_path)
	else:
		creation_folder = file_explorer_folders.find_key(selected_treefile)

func _create_motion_file(file_name: String) -> void:
	var motion_file := MotionDirector.new()
	var file_path: String = creation_folder + file_name.to_lower() + ".res"
	ResourceSaver.save(motion_file, file_path)
	selected_motion_path = file_path
	selected_motion_name = _get_file_name(file_path)
	motion_creator.update()
	_new_files()
	await populated
	_return_to_selected_item()	

func _create_folder(folder_name: String) -> void:
	var path: String = creation_folder + folder_name + "/"
	file_access_directory.make_dir(path)
	_new_files()
	await populated
	_explorer_select_folder(path)

func _prepare_copy() -> void:
	copy_item = selected_treefile
	copy_path = file_explorer_all_files.find_key(copy_item)
	if copy_path.ends_with("/"):
		copy_item_name = _get_folder_name(copy_path)
		copy_item_type = 0
	else:
		copy_item_name = _get_file_name(copy_path)
		copy_item_type = 1
	copy_parent_item = copy_item.get_parent()
	interface_toggle(ccp_button_groups, 1)
	file_explorer.deselect_all()
	update()

func _cancel_copy() -> void:
	is_moving_file = false
	copy_item.visible = true
	interface_toggle(ccp_button_groups, 0)

func _paste_item_check() -> void:
	var needs_rename: bool = false
	var invalid_names: PackedStringArray
	paste_path = file_explorer_all_files.find_key(selected_treefile)
	if paste_path.ends_with("/"):
		paste_path_type = 0
		var child_names: PackedStringArray
		if copy_item_type == 0:
			child_names = _get_children_folder_names(paste_path)
		else:
			child_names = _get_children_file_names(paste_path)
		for child_name in child_names:
			if copy_item_name == child_name:
				invalid_names.append(child_name)
				needs_rename = true
	else:
		paste_path_type = 1
		var sibling_names: PackedStringArray
		if copy_item_type == 0:
			sibling_names = _get_sibling_names(paste_path, 1)
		else:
			sibling_names = _get_sibling_names(paste_path, 2)
		for sibling_name in sibling_names:
			if copy_item_name == sibling_name:
				invalid_names.append(sibling_name)
				needs_rename = true
	
	if needs_rename:
		var description: String = "Name the new Motion Director file"
		main_panel.line_edit_popup(self._paste_item, description, invalid_names)
	else:
		_paste_item(copy_item_name)

func _paste_item(name: String) -> void:
	if copy_item_type == 0:
		name += "/"
	else:
		name += ".res"
	if paste_path_type == 0:
		paste_path = paste_path + name
	else:
		paste_path = _get_parent_folder(paste_path) + name
	
	if is_moving_file:
		file_access_directory.rename_absolute(copy_path,paste_path)
	else:
		file_access_directory.copy(copy_path,paste_path)
	
	is_moving_file = false
	interface_toggle(ccp_button_groups, 0)
	_new_files()
	await populated
	if copy_item_type == 0:
		_explorer_select_folder(paste_path)
	else:
		selected_motion_path = paste_path
		_return_to_selected_item()

func _rename_file(name: String, parent_dir: String = "") -> void:
	var old_path: String = file_explorer_all_files.find_key(selected_treefile)
	var new_path: String = _get_parent_folder(old_path) + name
	var type: int = selected_treefile_type
	if type == FILE_TYPES.MOTION_FILE:
		new_path +=  ".res"
	else:
		new_path += "/"
	file_access_directory.rename_absolute(old_path, new_path)
	selected_motion_path = new_path
	selected_motion_name = name.capitalize()
	_new_files()
	await populated
	if type == FILE_TYPES.MOTION_FILE:
		_return_to_selected_item()
	else:
		_explorer_select_folder(new_path)

func _delete_file() -> void:
	var delete_path: String = file_explorer_all_files.find_key(selected_treefile)
	var parent_path: String = _get_parent_folder(delete_path)
	OS.move_to_trash(ProjectSettings.globalize_path(delete_path))
	_new_files()
	await populated
	if selected_motion_path in file_explorer_files.keys():
		_return_to_selected_item()
	else:
		_explorer_select_folder(parent_path)
		selected_motion_path = ""
	motion_creator.update()


# UI INTERACTION
func _on_file_explorer_tree_item_selected():
	update()

## Explorer Control
func _on_expand_all_button_pressed():
	_explorer_expand_all()

func _on_collapse_all_button_pressed():
	_explorer_collapse_all()

func _on_file_return_to_button_pressed():
	_return_to_selected_item()

func _on_file_refresh_button_pressed():
	has_new_files = true
	_populate_interface()

## Tools
func _on_file_add_button_pressed():
	_assign_creation_folder()
	var description: String = "Name the new Motion Director file"
	main_panel.line_edit_popup(self._create_motion_file, description, _get_children_file_names(creation_folder))

func _on_file_add_folder_button_pressed():
	_assign_creation_folder()
	var description: String = "Name the new folder"
	main_panel.line_edit_popup(self._create_folder, description, _get_children_folder_names(creation_folder))

func _on_file_copy_button_pressed():
	_prepare_copy()

func _on_file_cut_button_pressed():
	selected_treefile.visible = false
	_prepare_copy()
	is_moving_file = true

func _on_file_paste_button_pressed():
	_paste_item_check()

func _on_file_cancel_button_pressed():
	_cancel_copy()

func _on_file_rename_button_pressed():
	_update_selected_file()
	var selected_path: String = file_explorer_all_files.find_key(selected_treefile)
	var description: String = "Select a new name"
	main_panel.line_edit_popup(self._rename_file, description, _get_sibling_names(selected_path))

func _on_file_delete_button_pressed():
	var name: String
	if selected_treefile_type == FILE_TYPES.MOTION_FILE:
		name = selected_motion_name + " Motion Director file?"
	else:
		name = _get_folder_name(file_explorer_folders.find_key(selected_treefile)) + " folder and all its contents?"
	var description: String = "WARNING!!! Are you sure you want to delete the " + name 
	main_panel.yes_no_popup(self._delete_file, description)
