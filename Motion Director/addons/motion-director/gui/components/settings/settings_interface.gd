@tool
extends MotionDirectorInterface


signal settings_updated


# VARIABLES
## Children
@onready var file_dialog: FileDialog = $FileDialog
@onready var settings_options: ItemList = $%SettingsOptionsList
### General
@onready var general_interface: MarginContainer = $%GeneralInterface
### Motions
@onready var motion_interface: MarginContainer = $%MotionInterface
@onready var motion_folders_list: ItemList = $%MotionFoldersList
@onready var motion_folders_select_up_button: Button = $%MotionFoldersSelectUpButton
@onready var motion_folders_select_down_button: Button = $%MotionFoldersSelectDownButton
@onready var motion_folders_delete_button: Button = $%MotionFoldersDeleteButton
### Experimental
@onready var experimental_interface: MarginContainer = $%ExperimentalInterface
### About
@onready var about_interface: MarginContainer = $%AboutInterface
@onready var about_label: Label = $%AboutLabel

## Constants
### Interface Groups
const options_interfaces: PackedStringArray = [
	"general_interface",
	"motion_interface",
	"experimental_interface",
	"about_interface"
]

## Values
var has_settings_update: bool = false


## Temp Values
var options_index: int = 0
var motion_folder_list_index: int


# INITIALISATION
func _ready_inject() -> void:
	settings_options.select(options_index)
	interface_toggle(options_interfaces, 0)
	_populate_about()

func _populate_about() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.load("res://addons/motion-director/plugin.cfg")
	var text: String = config.get_value("plugin", "name") + "\n"
	text += config.get_value("plugin", "description") + "\n"
	text += config.get_value("plugin", "author") + "\n"
	text += "v" + config.get_value("plugin", "version")
	about_label.text = text


# SETTINGS
func save_settings() -> void:
	if has_settings_update:
		ResourceSaver.save(settings, settings.save_path)
		has_settings_update = false
		settings_updated.emit()


# SHOW/HIDE
func settings_show() -> void:
	options_index = 0
	settings_options.select(options_index)
	interface_toggle(options_interfaces, 0)
	show()

func settings_exit() -> void:
	save_settings()
	hide()


# POPULATE UI
func _populate_interface() -> void:
	match options_index:
		0:
			pass
		1:
			_populate_motions()
		2:
			pass

func _populate_motions() -> void:
	motion_folders_list.clear()
	motion_folders_list.add_item(_get_rootless_path(settings.default_motion_folder))
	var error_dir: DirAccess
	var error_dirs: PackedInt32Array
	for motion_folder in settings.motion_folders:
		error_dir = DirAccess.open(motion_folder)
		if error_dir:
			motion_folders_list.add_item(_get_rootless_path(motion_folder))
		else:
			var remove_index: int = settings.motion_folders.find(motion_folder)
			error_dirs.append(remove_index)
	
	# Remove any no longer existing directories
	for error in error_dirs:
		settings.motion_folders.remove_at(error)
	has_settings_update = true
	save_settings()


# UI UPDATES
func _update_interface() -> void:
	match options_index:
		0:
			pass
		1:
			_update_motions()
		2:
			pass
		3:
			pass

func _update_motions() -> void:
	motion_folders_select_up_button.disabled = true
	motion_folders_select_down_button.disabled = true
	motion_folders_delete_button.disabled = true
	if not motion_folders_list.is_anything_selected():
		motion_folder_list_index = 0
		if not motion_folder_list_index > motion_folders_list.item_count - 1:
			motion_folders_list.select(motion_folder_list_index)
	if motion_folder_list_index > 0:
		motion_folders_delete_button.disabled = false
	if motion_folders_list.item_count > 1:
		motion_folders_select_up_button.disabled = false
		motion_folders_select_down_button.disabled = false


# FILE INFORMATION
func _get_rootless_path(path: String) -> String:
	var edit_index: int = 6
	path = path.substr(edit_index)
	return path


# UI INTERACTION
func _on_settings_options_list_item_clicked(index, _at_position, _mouse_button_index):
	options_index = index
	interface_toggle(options_interfaces, index)
	update()

## Motions
func _add_motion_folder(folder: String) -> void:
	main_panel._refresh_files()
	if folder == "res://":
		return
	folder += "/"
	if folder in settings.motion_folders:
		return
	settings.motion_folders.append(folder)
	has_settings_update = true
	save_settings()
	update()

func _delete_motion_folder() -> void:
	var folder: String = motion_folders_list.get_item_text(motion_folder_list_index)
	var delete_index: int = settings.motion_folders.find("res://" + folder)
	settings.motion_folders.remove_at(delete_index)
	_switch_list_selection(motion_folders_list, "motion_folder_list_index", true)
	has_settings_update = true
	save_settings()
	update()

func _on_motion_folders_select_up_button_pressed():
	_switch_list_selection(motion_folders_list, "motion_folder_list_index", true)

func _on_motion_folders_select_down_button_pressed():
	_switch_list_selection(motion_folders_list, "motion_folder_list_index")

func _on_motion_folders_add_button_pressed():
	file_dialog.current_dir = "res://"
	file_dialog.show()
	if not file_dialog.canceled.is_connected(main_panel._refresh_files):
		file_dialog.canceled.connect(main_panel._refresh_files, CONNECT_PERSIST)
	if not file_dialog.dir_selected.is_connected(_add_motion_folder):
		file_dialog.dir_selected.connect(_add_motion_folder, CONNECT_PERSIST)

func _on_motion_folders_delete_button_pressed():
	var description: String = "Are you sure you want to remove this frolder from the motion folders?"
	main_panel.yes_no_popup(self._delete_motion_folder, description)
