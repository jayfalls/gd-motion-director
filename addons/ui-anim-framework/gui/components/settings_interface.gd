@tool
extends UIAnimationInterface


# VARIABLES
## Children
@onready var file_dialog: FileDialog = $FileDialog
@onready var settings_options: ItemList = $%SettingsOptionsList
### General
@onready var general_interface: MarginContainer = $%GeneralInterface
### Animations
@onready var animations_interface: MarginContainer = $%AnimationsInterface
@onready var animation_folders_list: ItemList = $%AnimationFoldersList
@onready var animation_folders_select_up_button: Button = $%AnimationFoldersSelectUpButton
@onready var animation_folders_select_down_button: Button = $%AnimationFoldersSelectDownButton
@onready var animation_folders_delete_button: Button = $%AnimationFoldersDeleteButton
### Experimental
@onready var experimental_interface: MarginContainer = $%ExperimentalInterface
### About
@onready var about_interface: MarginContainer = $%AboutInterface
@onready var about_label: Label = $%AboutLabel

## Constants
### Interface Groups
const options_interfaces: PackedStringArray = [
	"general_interface",
	"animations_interface",
	"experimental_interface",
	"about_interface"
]


## Temp Values
var options_index: int = 0
var animation_folder_list_index: int


# INITIALISATION
func _ready():
	load_settings()
	settings_options.select(options_index)
	interface_toggle(options_interfaces, 0)
	_populate_about()

func _populate_about() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.load("res://addons/ui-anim-framework/plugin.cfg")
	var text: String = config.get_value("plugin", "name") + "\n"
	text += config.get_value("plugin", "description") + "\n"
	text += config.get_value("plugin", "author") + "\n"
	text += "v" + config.get_value("plugin", "version")
	about_label.text = text


# SETTINGS
func save_settings() -> void:
	if settings.has_changed:
		ResourceSaver.save(settings, settings.save_path)


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
			_populate_animations()
		2:
			pass

func _populate_animations() -> void:
	animation_folders_list.clear()
	animation_folders_list.add_item(_get_rootless_path(settings.default_animation_folder))
	for anim_folder in settings.animation_folders:
		animation_folders_list.add_item(_get_rootless_path(anim_folder))


# UI UPDATES
func _update_interface() -> void:
	match options_index:
		0:
			pass
		1:
			_update_animations()
		2:
			pass
		3:
			pass

func _update_animations() -> void:
	animation_folders_select_up_button.disabled = true
	animation_folders_select_down_button.disabled = true
	animation_folders_delete_button.disabled = true
	if not animation_folders_list.is_anything_selected():
		animation_folder_list_index = 0
		animation_folders_list.select(animation_folder_list_index)
	if animation_folder_list_index > 0:
		animation_folders_delete_button.disabled = false
	if animation_folders_list.item_count > 1:
		animation_folders_select_up_button.disabled = false
		animation_folders_select_down_button.disabled = false


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

## Animations
func _add_animation_folder(folder: String) -> void:
	folder += "/"
	if folder in settings.animation_folders:
		return
	settings.animation_folders.append(folder)
	save_settings()
	update()

func _delete_animation_folder() -> void:
	var folder: String = animation_folders_list.get_item_text(animation_folder_list_index)
	var delete_index: int = settings.animation_folders.find("res://" + folder)
	settings.animation_folders.remove_at(delete_index)
	_switch_list_selection(animation_folders_list, "animation_folder_list_index", true)
	save_settings()
	update()

func _on_animation_folders_select_up_button_pressed():
	_switch_list_selection(animation_folders_list, "animation_folder_list_index", true)

func _on_animation_folders_select_down_button_pressed():
	_switch_list_selection(animation_folders_list, "animation_folder_list_index")

func _on_animation_folders_add_button_pressed():
	file_dialog.show()
	file_dialog.dir_selected.connect(_add_animation_folder)

func _on_animation_folders_delete_button_pressed():
	var description: String = "Are you sure you want to remove this frolder from the animation folders?"
	main_panel.yes_no_popup(self._delete_animation_folder, description)
