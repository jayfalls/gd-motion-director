@tool
extends MotionDirectorInterface


# VARIABLES
## References
var file_explorer: MotionDirectorInterface

## Children
@onready var current_selected_label: Label = $%CurrentSelectedLabel
@onready var motion_tools_interface: HBoxContainer = $%MotionToolsInterface
### Motion Tree
@onready var motiontree: Tree = $%MotionTree
#### Control Tools
@onready var cancel_tool_panel: VBoxContainer = $%CancelToolPanel
@onready var move_directionn_icon: TextureRect = $%MoveDirectionIcon
@onready var move_tools: VBoxContainer = $%MoveTools
@onready var move_up_button: Button = $%MoveUpButton
@onready var move_down_button: Button = $%MoveDownButton
#### Create Tools
@onready var add_chaining_button: Button = $%AddChainingButton
@onready var add_action_button: Button = $%AddActionButton
@onready var add_controlflow_button: Button = $%AddControlflowButton
@onready var delete_gd_button: Button = $%DeleteGDButton
### Instructions Interface
@onready var instructions_interface: VBoxContainer = $%InstructionsInterface
@onready var instructions_label: Label = $%InstructionsLabel
@onready var confirm_reparent_button: Button = $%ConfirmReparentButton
### Properties
@onready var properties_interface: VBoxContainer = $%PropertiesInterface
@onready var tool_options_button: OptionButton = $%ToolOptionsButton
### Controls
@onready var controls_interface: MarginContainer = $%ControlsInterface
@onready var main_settings: HBoxContainer = $%MainSettings
### Property Type
@onready var property_type_interface : MarginContainer = $%PropertyTypeInterface
@onready var property_options_button: OptionButton = $%PropertyOptionsButton
#### None
@onready var no_property_interface: MarginContainer = $%NoPropertyInterface
#### Delay
@onready var delay_interface: MarginContainer = $%DelayInterface
#### Speed
@onready var speed_interface: MarginContainer = $%SpeedInterface
#### Curve
@onready var curve_interface: MarginContainer = $%CurveInterface
#### Easing
@onready var easing_interface: HBoxContainer = $%EasingInterface
@onready var ease_curve_visualiser: EaseCurveVisualiser = $%EaseCurveVisualiser
@onready var easing_value_slider: HSlider = $%EasingValueSlider
@onready var easing_presets_button: OptionButton = $%EasingPresetsButton

## Constants
const main_interfaces: PackedStringArray = [
	"instructions_interface",
	"properties_interface"
]
const properties_interfaces: PackedStringArray = [
	"controls_interface",
	"property_type_interface"
]
const controls_interfaces: PackedStringArray = [
	"main_settings"
]
const property_type_interfaces: PackedStringArray = [
	"no_property_interface",
	"delay_interface",
	"speed_interface",
	"curve_interface",
	"easing_interface"
]
### Motion Tree
enum GDACTION_TYPES {
	ROOT,
	CHAINING,
	CONTROL_FLOW,
	ACTION
}
const move_buttons: PackedStringArray = [
	"move_tools",
	"cancel_tool_panel"
]
const move_direction_icons: Array[CompressedTexture2D] = [
	preload("res://addons/motion-director/gui/icons/tools/select_up_icon.png"),
	preload("res://addons/motion-director/gui/icons/tools/select_down_icon.png")
]

## UI Information
const constant_name_arrays: PackedStringArray = [
	"chaining_names",
	"control_flow_names",
	"action_names",
	"property_types_names"
]
var chaining_names: PackedStringArray
@onready var chaining_icons: Array[CompressedTexture2D] = [
	preload("res://addons/motion-director/gui/icons/gdaction/chaining/sequence_icon.png"),
	preload("res://addons/motion-director/gui/icons/gdaction/chaining/group_icon.png"),
	preload("res://addons/motion-director/gui/icons/gdaction/chaining/if_else_icon.png"),
	preload("res://addons/motion-director/gui/icons/gdaction/chaining/while_icon.png"),
	preload("res://addons/motion-director/gui/icons/gdaction/chaining/repeat_icon.png"),
	preload("res://addons/motion-director/gui/icons/gdaction/chaining/repeat_forever_icon.png")
]
var control_flow_names: PackedStringArray
@onready var control_flow_icons: Array[CompressedTexture2D] = [
	preload("res://addons/motion-director/gui/icons/gdaction/flow_control/wait_icon.png"),
	preload("res://addons/motion-director/gui/icons/gdaction/flow_control/pause_icon.png"),
	preload("res://addons/motion-director/gui/icons/gdaction/flow_control/resume_icon.png"),
	preload("res://addons/motion-director/gui/icons/gdaction/flow_control/cancel_icon.png"),
]
var action_names: PackedStringArray
@onready var action_icon: CompressedTexture2D = preload("res://addons/motion-director/gui/icons/gdaction/actions/action_icon.png")
var property_types_names: PackedStringArray

## Temp Values
### Motion File
var saving: bool = false
var load_failed: bool = false
var motion_file: MotionDirector
var current_motion_path: String = "" # Path to the motion file
var current_motion_name: String
var detecting_selected: bool = false
var motion_changed: bool = false
### Motion Tree
var motiontree_changed: bool = false
var filling_tree: bool = false
var motiontree_root: TreeItem
var filled_children: int
var children_filled: bool = true
var motiontree_chains: Dictionary
var motiontree_control_flows: Dictionary
var motiontree_actions: Dictionary
var motiontree_all_items: Dictionary
var motiontree_structure: Dictionary
#### Current TreeItem
var selected_motiontree_path: String
var selected_motiontree_type: int
#### Editing
var editing: bool = false
var editing_selected_path: String
var moving_up: bool
var create_motiontree_type: int

# INITIALISATION
func _ready_inject() -> void:
	await get_tree().process_frame
	
	_get_constants_names()
	interface_toggle(properties_interfaces, 0)
	
	# Property Types Interface
	property_options_button.clear()
	for type in property_types_names:
		property_options_button.add_item(type)
	easing_presets_button.clear()
	for preset in MotionDirectorConstants.EASING_PRESETS.keys():
		easing_presets_button.add_item(preset)
	interface_toggle(property_type_interfaces, 0)

func _get_constants_names() -> void:
	for array in constant_name_arrays:
		self[array].clear()
		var constant_name: String = array.replace("_names", "").to_upper()
		for key_name in MotionDirectorConstants[constant_name]:
			self[array].append(key_name.capitalize())


# ANIM FILE
func _load_motion_file() -> void:
	if ResourceLoader.exists(current_motion_path):
		motion_file = ResourceLoader.load(current_motion_path, "", 0)
	else:
		file_explorer._new_files()
		load_failed = true

func _save_motion_file() -> void:
	saving = true
	motion_file.motions = motiontree_structure
	motion_file.take_over_path(current_motion_path)
	var saving = ResourceSaver.save(motion_file, current_motion_path)
	motion_changed = true
	saving = false


# POPULATE UI
func _populate_interface() -> void:
	while saving:
		pass
	_detect_selected_motion()
	while detecting_selected:
		pass
	if not ResourceLoader.exists(current_motion_path):
		motion_changed = true
		current_motion_path = ""
	_change_current_motion_name()
	if not motion_changed:
		populated.emit()
		populating = false
		return
	
	populating = true
	if current_motion_path == "":
		motion_file == null
	else:
		_load_motion_file()
	if load_failed:
		load_failed = false
		current_motion_path = ""
		_change_current_motion_name()
		return
	tool_options_button.select(0)
	motion_changed = false
	motiontree_changed = true
	_normal_ui()	
	selected_motiontree_path = "."
	populated.emit()
	populating = false

func _detect_selected_motion() -> void:
	detecting_selected = true
	var selected_motion_path = file_explorer.selected_motion_path
	if selected_motion_path == current_motion_path or motion_changed:
		detecting_selected = false
		return	
	motion_changed = true
	current_motion_path = selected_motion_path
	current_motion_name = file_explorer.selected_motion_name
	detecting_selected = false

func _change_current_motion_name() -> void:
	if current_motion_path == "":
		current_selected_label.add_theme_color_override("font_color", Color.ORANGE)
		current_selected_label.text = "None"
	else:
		current_selected_label.add_theme_color_override("font_color", Color.GREEN)
		current_selected_label.text = current_motion_name


# UI UPDATES
func _update_interface() -> void:
	await populated
	if current_motion_path == "":
		motion_tools_interface.hide()
		return
		
	if motiontree_changed and not filling_tree:
		_update_motiontree()
	
	interface_toggle(properties_interfaces, 0)	

	_determine_selected_type()
	if editing:
		_disable_motiontree_tools()
		_detect_valid_move()
		return
	_set_motiontree_tools()

	_set_ui_to_gd_type()

	motion_tools_interface.show()

func _update_motiontree() -> void:
	filling_tree = true
	_clear_motiontree()
	_fill_motiontree()

func _clear_motiontree() -> void:
	motiontree.deselect_all()
	motiontree.clear()
	motiontree_structure.clear()
	motiontree_chains.clear()
	motiontree_control_flows.clear()
	motiontree_actions.clear()
	motiontree_all_items.clear()

func _fill_motiontree() -> void:	
	motiontree_structure = motion_file.motions
	motiontree_root = motiontree.create_item()
	motiontree_chains["."] = motiontree_root
	var details: Dictionary = motiontree_structure["."]
	var gda_name: String = details["name"]
	motiontree_root.set_text(0, gda_name)
	motiontree_root.set_icon(0, chaining_icons[chaining_names.find(gda_name)])
	filled_children = 1
	children_filled = false
	_fill_motiontree_children(motiontree_root, details["children"])
	
	while not children_filled:
		pass
	motiontree_all_items.merge(motiontree_chains)
	motiontree_all_items.merge(motiontree_control_flows)
	motiontree_all_items.merge(motiontree_actions)
	if selected_motiontree_path == "" or not selected_motiontree_path in motiontree_all_items.keys():
		selected_motiontree_path = "."
	
	motiontree.set_selected(motiontree_all_items[selected_motiontree_path], 0)
	filling_tree = false
	motiontree_changed = false

func _fill_motiontree_children(parent_item: TreeItem, children_paths: PackedStringArray) -> void:
	var dummy_children: Array[TreeItem]
	for dummy in children_paths:
		dummy_children.append(motiontree.create_item(parent_item))
	
	for child_path in children_paths:
		var child_details: Dictionary = motiontree_structure[child_path]
		var child_gda_name: String = child_details["name"]
		var child_index: int = child_details["index"]
	
		var motiontree_item: TreeItem = motiontree.create_item(parent_item, child_index)
		dummy_children[child_index].free()
		motiontree_item.set_text(0, child_gda_name)
		if child_gda_name in chaining_names:
			motiontree_chains[child_path] = motiontree_item
			motiontree_chains[child_path].set_icon(0, chaining_icons[chaining_names.find(child_gda_name)])
			_fill_motiontree_children(motiontree_item, child_details["children"])
		elif child_gda_name in control_flow_names:
			motiontree_control_flows[child_path] = motiontree_item
			motiontree_control_flows[child_path].set_icon(0, control_flow_icons[control_flow_names.find(child_gda_name)])
		else:
			motiontree_actions[child_path] = motiontree_item
			motiontree_actions[child_path].set_icon(0, action_icon)
		
		filled_children += 1
	
	if filled_children == motiontree_structure.size():
		children_filled = true

func _determine_selected_type() -> void:
	var selected_treeitem: TreeItem = motiontree.get_selected()
	selected_motiontree_path = motiontree_all_items.find_key(selected_treeitem)
	if selected_treeitem == motiontree_root:
		selected_motiontree_type = GDACTION_TYPES.ROOT
	elif selected_treeitem in motiontree_chains.values():
		selected_motiontree_type = GDACTION_TYPES.CHAINING
	elif selected_treeitem in motiontree_control_flows.values():
		selected_motiontree_type = GDACTION_TYPES.CONTROL_FLOW
	else:
		selected_motiontree_type = GDACTION_TYPES.ACTION

func _disable_motiontree_tools() -> void:
	add_chaining_button.disabled = true
	add_controlflow_button.disabled = true
	add_action_button.disabled = true
	delete_gd_button.disabled = true

func _set_motiontree_tools() -> void:
	add_chaining_button.disabled = true
	add_controlflow_button.disabled = true
	add_action_button.disabled = true
	_set_moving_buttons_disabled(true)
	delete_gd_button.disabled = true
	if selected_motiontree_type == GDACTION_TYPES.ROOT:
		return
	add_chaining_button.disabled = false 
	add_controlflow_button.disabled = false 
	add_action_button.disabled = false 
	_set_moving_buttons_disabled(false)
	var selected_parent: String = motiontree_structure[selected_motiontree_path]["parent"]
	if motiontree_structure[selected_parent]["children"].size() == 1:
		_set_moving_buttons_disabled(true)
		return
	delete_gd_button.disabled = false

func _set_moving_buttons_disabled(disabled: bool) -> void:
	move_up_button.disabled = disabled
	move_down_button.disabled  = disabled

func _set_ui_to_gd_type() -> void:
	tool_options_button.hide()
	match selected_motiontree_type:
		GDACTION_TYPES.ROOT:
			_update_root_selected()
		GDACTION_TYPES.CHAINING:
			_update_chaining_selected()
		GDACTION_TYPES.CONTROL_FLOW:
			_update_control_flow_selected()
		GDACTION_TYPES.ACTION:
			_update_action_selected()

func _update_root_selected() -> void:
	pass

func _update_chaining_selected() -> void:
	pass

func _update_control_flow_selected() -> void:
	pass

func _update_action_selected() -> void:
	tool_options_button.show()
	match tool_options_button.selected:
		0:
			interface_toggle(properties_interfaces, 0)
		1:
			interface_toggle(properties_interfaces, 1)
			_update_property_type()

func _update_property_type():
	var property_type: int = motion_file.property_type
	interface_toggle(property_type_interfaces, property_type)
	property_options_button.select(property_type)
	match property_type:
		MotionDirectorConstants.PROPERTY_TYPES.DELAY:
			pass
		MotionDirectorConstants.PROPERTY_TYPES.SPEED:
			pass
		MotionDirectorConstants.PROPERTY_TYPES.CURVE:
			pass
		MotionDirectorConstants.PROPERTY_TYPES.EASE:
			_update_ease()

func _update_ease() -> void:
	var easing_value: float = motion_file.easing_value
	ease_curve_visualiser.change_curve_value(easing_value)
	
	easing_value_slider.value = easing_value
	_update_selected_easing_preset(easing_value)

func _update_selected_easing_preset(value: float) -> void:
	var easing_presets: PackedFloat32Array = MotionDirectorConstants.EASING_PRESETS.values()
	if value in easing_presets:
		easing_presets_button.select(easing_presets.find(value))
	elif motion_file.easing_value == -1:
		easing_presets_button.select(0)
	else:
		easing_presets_button.select(-1)


# MOTION TREE STRUCTURE
## Manipulation
func _update_motiontree_indexes(parent: String) -> void:
	var old_index: int = motiontree_structure[editing_selected_path]["index"]
	var new_index: int = _determine_new_index(false)
	if new_index < old_index:
		_reorder_higher_indexes(parent, old_index, true)
		_reorder_higher_indexes(parent, new_index - 1)
	else:
		_reorder_higher_indexes(parent, new_index)
		_reorder_higher_indexes(parent, old_index, true)
	motiontree_structure[editing_selected_path]["index"] = new_index

func _remove_motiontree_child_from_parent(parent_path: String) -> void:
	var parent_children: PackedStringArray = motiontree_structure[parent_path]["children"]
	var remove_name_index: int = parent_children.find(editing_selected_path)
	parent_children.remove_at(remove_name_index)
	motiontree_structure[parent_path]["children"] = parent_children
	var remove_index: int = motiontree_structure[editing_selected_path]["index"]
	_reorder_higher_indexes(parent_path, remove_index, true)

func _add_motiontree_child_to_parent(parent_path: String, no_other_children: bool = false) -> void:
	if not no_other_children:
		_add_to_children_indexes(parent_path)
	_add_name_to_parent_children(parent_path)
	motiontree_structure[editing_selected_path]["parent"] = parent_path

func _add_to_children_indexes(parent_path: String) -> void:
	var new_index: int = _determine_new_index()
	_reorder_higher_indexes(parent_path, new_index - 1)
	motiontree_structure[editing_selected_path]["index"] = new_index

func _determine_new_index(add: bool = true) -> int:
	var selected_index: int = motiontree_structure[selected_motiontree_path]["index"]
	var new_index: int
	if moving_up:
		if selected_index == 0:
			new_index = 0
		else:
			new_index = selected_index
	else:
		if add:
			new_index = selected_index + 1
		else:
			new_index = selected_index
	return new_index

func _add_name_to_parent_children(parent_path: String) -> void:
	var new_children: PackedStringArray = motiontree_structure[parent_path]["children"]
	var new_child_name: String = editing_selected_path.get_file()
	var new_child_path: String = parent_path + "/" + new_child_name
	new_child_path = _fix_duplicates(parent_path, new_child_path)
	selected_motiontree_path = new_child_path
	new_children.append(new_child_path)
	motiontree_structure[parent_path]["children"] = new_children

func _fix_duplicates(parent_path: String, new_path: String) -> String:
	var temp_path: String = new_path
	var parent_children: PackedStringArray = motiontree_structure[parent_path]["children"]
	var count: int = 1
	while temp_path in parent_children:
		temp_path = new_path + str(count)
		count += 1
	return temp_path

func _update_motiontree_name(remove: bool = false) -> void:
	if not remove:
		motiontree_structure[selected_motiontree_path] = motiontree_structure[editing_selected_path]
	motiontree_structure.erase(editing_selected_path)

func _reorder_higher_indexes(selected_parent_path: String, index: int, decrease: bool = false) -> void:
	var children: PackedStringArray = motiontree_structure[selected_parent_path]["children"]
	for child in children:
		var child_index: int = motiontree_structure[child]["index"] 
		if child_index <= index:
			continue

		var change: int
		if decrease:
			change = -1
		else:
			change = 1
		motiontree_structure[child]["index"] = child_index + change

## Editing
func _save_edit() -> void:
	editing = false
	_save_motion_file()
	update()

### Creation
func _create_motiontree_name(creation_parent_path: String, creation_type: int, only_child: bool = false) -> void:
	var new_motiontree_name: String
	var new_motiontree_path: String
	var new_motiontree_data: Dictionary
	match creation_type:
		GDACTION_TYPES.CHAINING:
			new_motiontree_name = chaining_names[0]
			new_motiontree_data = MotionDirectorConstants.DEFAULT_CHAINING.duplicate()
		GDACTION_TYPES.CONTROL_FLOW:
			new_motiontree_name = control_flow_names[0]
			new_motiontree_data = MotionDirectorConstants.DEFAULT_CONTROL_FLOW.duplicate()
		GDACTION_TYPES.ACTION:
			new_motiontree_name = action_names[0]
			new_motiontree_data = MotionDirectorConstants.DEFAULT_ACTION.duplicate()
	new_motiontree_path = creation_parent_path + "/" + new_motiontree_name
	var temp_path: String = new_motiontree_path
	var creation_parent_children: PackedStringArray = motiontree_structure[creation_parent_path]["children"]
	var count: int = 1
	while temp_path in creation_parent_children:
		temp_path = new_motiontree_path + str(count)
		count += 1
	new_motiontree_path = temp_path
	editing_selected_path = new_motiontree_path
	new_motiontree_data["parent"] = creation_parent_path
	motiontree_structure[new_motiontree_path] = new_motiontree_data
	editing_selected_path = new_motiontree_path
	_add_motiontree_child_to_parent(creation_parent_path, only_child)
	if creation_type == GDACTION_TYPES.CHAINING:
		_create_motiontree_name(new_motiontree_path, GDACTION_TYPES.ACTION, true)

func _add_motiontree_item() -> void:
	var selected_parent: String = motiontree_structure[selected_motiontree_path]["parent"]
	_create_motiontree_name(selected_parent, create_motiontree_type)
	_save_edit()

func _delete_motiontree_item() -> void:
	_delete_motiontree()
	_save_edit()

func _delete_motiontree(is_child: bool = false) -> void:
	var old_selected: String = selected_motiontree_path
	if motiontree_structure[selected_motiontree_path]["name"] in chaining_names:
		for child_path in motiontree_structure[selected_motiontree_path]["children"]:
			selected_motiontree_path = child_path
			_delete_motiontree(true)
	selected_motiontree_path = old_selected
	editing_selected_path = selected_motiontree_path
	if not is_child:
		var editing_parent: String = motiontree_structure[editing_selected_path]["parent"]
		_remove_motiontree_child_from_parent(editing_parent)
	_update_motiontree_name(true)

### Moving
#### Detection
func _detect_valid_move() -> void:
	instructions_label.add_theme_color_override("font_color", Color.WHITE)
	instructions_label.text = "Move GDAction"
	confirm_reparent_button.disabled = false 
	
	if selected_motiontree_type == GDACTION_TYPES.ROOT:
		_invalid_move("Cannot Be The Root")
		return
	var moving_name = motiontree_structure[editing_selected_path]["name"]
	if _is_invalid_move():
		_invalid_move("Cannot Be The Same")
		return
	if moving_name in chaining_names:
		var selected_parent: String = motiontree_structure[selected_motiontree_path]["parent"]
		var editing_parent: String = motiontree_structure[editing_selected_path]["parent"]
		if selected_parent != editing_parent:
			_invalid_move("Cannot Reparent a Chaining Action")
			return

func _invalid_move(reason: String) -> void:
	instructions_label.add_theme_color_override("font_color", Color.ORANGE)
	instructions_label.text = reason
	confirm_reparent_button.disabled = true

func _is_invalid_move() -> bool:
	if editing_selected_path == selected_motiontree_path:
		return true
	var editing_parent: String = motiontree_structure[editing_selected_path]["parent"]
	var editing_siblings: PackedStringArray = motiontree_structure[editing_parent]["children"]
	var sibling_selected: bool = selected_motiontree_path in editing_siblings
	if not sibling_selected:
		return false
	
	var moving_index: int = motiontree_structure[editing_selected_path]["index"] 
	var selected_motiontree_index: int = motiontree_structure[selected_motiontree_path]["index"]
	if moving_up:
			if moving_index == selected_motiontree_index - 1:
				return true
	else:
			if moving_index == selected_motiontree_index + 1:
				return true
	
	return false

#### Execution
func _move_motiontree_item() -> void:
	var selected_parent_path: String = motiontree_structure[selected_motiontree_path]["parent"]
	var editing_parent_path: String = motiontree_structure[editing_selected_path]["parent"]
	var same_parent: bool = selected_parent_path == editing_parent_path
	if same_parent: 
		_update_motiontree_indexes(selected_parent_path)
	else:
		_remove_motiontree_child_from_parent(editing_parent_path)
		_add_motiontree_child_to_parent(selected_parent_path)
		_update_motiontree_name()
	_save_edit()


# UI INTERACTION
## Motion Tree
func _on_motion_tree_item_selected():
	update()

### Control Tools
func _on_move_up_button_pressed():
	moving_up = true
	_move_ui()

func _on_move_down_button_pressed():
	moving_up = false
	_move_ui()

func _normal_ui() -> void:
	editing = false
	interface_toggle(main_interfaces, 1)
	interface_toggle(move_buttons, 0)
	update()

func _move_ui() -> void:
	editing = true
	editing_selected_path = motiontree_all_items.find_key(motiontree.get_selected())
	interface_toggle(main_interfaces, 0)
	interface_toggle(move_buttons, 1)
	var icon_index: int
	if moving_up:
		icon_index = 0
	else:
		icon_index = 1
	move_directionn_icon.texture = move_direction_icons[icon_index]
	update()

func _on_confirm_reparent_button_pressed():
	_move_motiontree_item()
	_normal_ui()	

func _on_cancel_move_button_pressed():	
	_normal_ui()	

### Create Tools
func _on_add_action_button_pressed():
	create_motiontree_type = GDACTION_TYPES.ACTION
	_add_motiontree_item()

func _on_add_controlflow_button_pressed():
	create_motiontree_type = GDACTION_TYPES.CONTROL_FLOW
	_add_motiontree_item()

func _on_add_chaining_button_pressed():
	create_motiontree_type = GDACTION_TYPES.CHAINING
	_add_motiontree_item()

func _on_delete_gd_button_pressed():
	_delete_motiontree_item()

## Action Selected
func _on_tool_options_button_item_selected(index):
	update()

### Property Types
func _on_property_options_button_item_selected(index):
	motion_file.property_type = index
	_save_motion_file()
	update()

#### Ease
func _change_slider_zero_value(value: float) -> float:
	if value == 0:
		if motion_file.easing_value < 0:
			value -= 0.2
		else:
			value += 0.2
	return value

func _on_easing_value_slider_value_changed(value):
	ease_curve_visualiser.change_curve_value(value)
	_update_selected_easing_preset(value)
	var dif_val: float = _change_slider_zero_value(value)
	if value != dif_val:
		easing_value_slider.value = dif_val

func _on_easing_value_slider_drag_ended(_value_changed):
	var changed_val: float = snapped(easing_value_slider.value, 0.1)
	changed_val = _change_slider_zero_value(changed_val)
	
	motion_file.easing_value = changed_val
	_save_motion_file()
	update()

func _on_easing_presets_button_item_selected(index):
	var preset_name: String = easing_presets_button.get_item_text(index)
	motion_file.easing_value = MotionDirectorConstants.EASING_PRESETS[preset_name]
	_save_motion_file()
	update()

