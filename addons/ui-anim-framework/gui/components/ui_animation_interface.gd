@tool
class_name UIAnimationInterface extends MarginContainer


# VARIABLES
## Constants
const cache_directory: String = "res://addons/ui-anim-framework/data/cache/"
## File Access
@onready var editor_dir: DirAccess = DirAccess.open("res://")

## References
@onready var settings: UIAnimationSettings
@onready var main_panel: UIAnimationPanel


# INITIALISATION
func _ready():
	load_settings()
	_ready_inject()

func _ready_inject() -> void:
	pass
	

# SETTINGS
func load_settings() -> void:
	if editor_dir.file_exists(settings.save_path):
		settings = ResourceLoader.load(settings.save_path)
	else:
		settings = UIAnimationSettings.new()


# POPULATE/UPDATE UI
func update() -> void:
	_populate_interface()
	_update_interface()

func _populate_interface() -> void:
	pass

func _update_interface() -> void:
	pass

## Toggle between interfaces
func interface_toggle(group: PackedStringArray, index: int) -> void:
	if self[group[index]].visible:
		return
	for variable_ref in group:
		self[variable_ref].hide()
	self[group[index]].show()

## Up & Down controls for item lists
func _switch_list_selection(list: ItemList, list_index: String, previous: bool = false) -> void:
	if not list.is_anything_selected():
		self[list_index] = -1
	
	if previous:
		if self[list_index] <= 0:
			self[list_index] = list.item_count - 1
		else:
			self[list_index] -= 1
	else:
		if self[list_index] >= list.item_count - 1:
			self[list_index] = 0
		else:
			self[list_index] += 1
	
	list.select(self[list_index])
	_update_interface()
