@tool
extends UIAnimationInterface


# VARIABLES
## References
var file_explorer: UIAnimationInterface

## Children
@onready var current_selected_label: Label = $%CurrentSelectedLabel
@onready var animation_tools_interface: HBoxContainer = $%AnimationToolsInterface
### Animation Tree
@onready var animtree: Tree = $%AnimationTree
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
### Animation Tree
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
	preload("res://addons/ui-anim-framework/gui/icons/tools/select_up_icon.png"),
	preload("res://addons/ui-anim-framework/gui/icons/tools/select_down_icon.png")
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
	preload("res://addons/ui-anim-framework/gui/icons/gdaction/chaining/sequence_icon.png"),
	preload("res://addons/ui-anim-framework/gui/icons/gdaction/chaining/group_icon.png"),
	preload("res://addons/ui-anim-framework/gui/icons/gdaction/chaining/if_else_icon.png"),
	preload("res://addons/ui-anim-framework/gui/icons/gdaction/chaining/while_icon.png"),
	preload("res://addons/ui-anim-framework/gui/icons/gdaction/chaining/repeat_icon.png"),
	preload("res://addons/ui-anim-framework/gui/icons/gdaction/chaining/repeat_forever_icon.png")
]
var control_flow_names: PackedStringArray
@onready var control_flow_icons: Array[CompressedTexture2D] = [
	preload("res://addons/ui-anim-framework/gui/icons/gdaction/flow_control/wait_icon.png"),
	preload("res://addons/ui-anim-framework/gui/icons/gdaction/flow_control/pause_icon.png"),
	preload("res://addons/ui-anim-framework/gui/icons/gdaction/flow_control/resume_icon.png"),
	preload("res://addons/ui-anim-framework/gui/icons/gdaction/flow_control/cancel_icon.png"),
]
var action_names: PackedStringArray
@onready var action_icon: CompressedTexture2D = preload("res://addons/ui-anim-framework/gui/icons/gdaction/actions/action_icon.png")
var property_types_names: PackedStringArray

## Temp Values
### Animation File
var saving: bool = false
var load_failed: bool = false
var anim_file: UIAnimation
var current_anim: String = "" # Path to the anim file
var current_anim_name: String
var detecting_selected: bool = false
var anim_changed: bool = false
### Animation Tree
var animtree_changed: bool = false
var filling_tree: bool = false
var animtree_root: TreeItem
var filled_children: int
var children_filled: bool = true
var animtree_chains: Dictionary
var animtree_control_flows: Dictionary
var animtree_actions: Dictionary
var animtree_all_items: Dictionary
var animtree_structure: Dictionary
#### Current TreeItem
var selected_animtree: String
var selected_animtree_type: int
#### Editing
var editing: bool = false
var editing_selected: String
var moving_up: bool
var create_animtree_type: int

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
	for preset in UIAnimationConstants.EASING_PRESETS.keys():
		easing_presets_button.add_item(preset)
	interface_toggle(property_type_interfaces, 0)

func _get_constants_names() -> void:
	for array in constant_name_arrays:
		self[array].clear()
		var constant_name: String = array.replace("_names", "").to_upper()
		for key_name in UIAnimationConstants[constant_name]:
			self[array].append(key_name.capitalize())


# ANIM FILE
func _load_anim_file() -> void:
	if ResourceLoader.exists(current_anim):
		anim_file = ResourceLoader.load(current_anim, "", 0)
	else:
		file_explorer._new_files()
		load_failed = true

func _save_anim_file() -> void:
	saving = true
	anim_file.animations = animtree_structure
	anim_file.take_over_path(current_anim)
	var saving = ResourceSaver.save(anim_file, current_anim)	
	anim_changed = true
	saving = false


# POPULATE UI
func _populate_interface() -> void:
	while saving:
		pass
	_detect_selected_anim()
	while detecting_selected:
		pass
	if not ResourceLoader.exists(current_anim):
		anim_changed = true
		current_anim = ""
	_change_current_anim_name()
	if not anim_changed:
		populated.emit()
		populating = false
		return
	
	populating = true
	if current_anim == "":
		anim_file == null
	else:
		_load_anim_file()
	if load_failed:
		load_failed = false
		current_anim = ""
		_change_current_anim_name()
		return
	tool_options_button.select(0)
	anim_changed = false
	animtree_changed = true
	_normal_ui()	
	selected_animtree = "."
	populated.emit()
	populating = false

func _detect_selected_anim() -> void:
	detecting_selected = true
	var selected_anim = file_explorer.selected_anim
	if selected_anim == current_anim or anim_changed:
		detecting_selected = false
		return	
	anim_changed = true
	current_anim = selected_anim
	current_anim_name = file_explorer.selected_anim_name	
	detecting_selected = false

func _change_current_anim_name() -> void:
	if current_anim == "":
		current_selected_label.add_theme_color_override("font_color", Color.ORANGE)
		current_selected_label.text = "None"
	else:
		current_selected_label.add_theme_color_override("font_color", Color.GREEN)
		current_selected_label.text = current_anim_name


# UI UPDATES
func _update_interface() -> void:
	await populated
	if current_anim == "":
		animation_tools_interface.hide()
		return
		
	if animtree_changed and not filling_tree:
		_update_animtree()
	
	interface_toggle(properties_interfaces, 0)	

	_determine_selected_type()
	if editing:
		_disable_animtree_tools()
		_detect_valid_move()
		return
	_set_animtree_tools()

	_set_ui_to_gd_type()

	animation_tools_interface.show()

func _update_animtree() -> void:
	filling_tree = true
	_clear_animtree()
	_fill_animtree()

func _clear_animtree() -> void:
	animtree.deselect_all()
	animtree.clear()
	animtree_structure.clear()
	animtree_chains.clear()
	animtree_control_flows.clear()
	animtree_actions.clear()
	animtree_all_items.clear()

func _fill_animtree() -> void:	
	animtree_structure = anim_file.animations
	animtree_root = animtree.create_item()
	animtree_chains["."] = animtree_root
	var details: Dictionary = animtree_structure["."]
	var gda_name: String = details["name"]
	animtree_root.set_text(0, gda_name)
	animtree_root.set_icon(0, chaining_icons[chaining_names.find(gda_name)])
	filled_children = 1
	children_filled = false
	_fill_animtree_children(animtree_root, details["children"])
	
	while not children_filled:
		pass
	animtree_all_items.merge(animtree_chains)
	animtree_all_items.merge(animtree_control_flows)
	animtree_all_items.merge(animtree_actions)
	if selected_animtree == "" or not selected_animtree in animtree_all_items.keys():
		selected_animtree = "."

	animtree.set_selected(animtree_all_items[selected_animtree], 0)
	filling_tree = false
	animtree_changed = false

func _fill_animtree_children(parent_item: TreeItem, children_paths: PackedStringArray) -> void:
	var dummy_children: Array[TreeItem]
	for dummy in children_paths:
		dummy_children.append(animtree.create_item(parent_item))
	
	for child_path in children_paths:
		var child_details: Dictionary = animtree_structure[child_path]
		var child_gda_name: String = child_details["name"]
		var child_index: int = child_details["index"]	

		var animtree_item: TreeItem = animtree.create_item(parent_item, child_index)
		dummy_children[child_index].free()
		animtree_item.set_text(0, child_gda_name)
		if child_gda_name in chaining_names:
			animtree_chains[child_path] = animtree_item
			animtree_chains[child_path].set_icon(0, chaining_icons[chaining_names.find(child_gda_name)])
			_fill_animtree_children(animtree_item, child_details["children"])
		elif child_gda_name in control_flow_names:
			animtree_control_flows[child_path] = animtree_item
			animtree_control_flows[child_path].set_icon(0, control_flow_icons[control_flow_names.find(child_gda_name)])
		else:
			animtree_actions[child_path] = animtree_item	
			animtree_actions[child_path].set_icon(0, action_icon)
		
		filled_children += 1

	#for dummy in dummy_children:
	#	dummy.free()

	if filled_children == animtree_structure.size():
		children_filled = true

func _determine_selected_type() -> void:
	var selected_treeitem: TreeItem = animtree.get_selected()
	selected_animtree = animtree_all_items.find_key(selected_treeitem)
	if selected_treeitem == animtree_root:
		selected_animtree_type = GDACTION_TYPES.ROOT
	elif selected_treeitem in animtree_chains.values():
		selected_animtree_type = GDACTION_TYPES.CHAINING
	elif selected_treeitem in animtree_control_flows.values():
		selected_animtree_type = GDACTION_TYPES.CONTROL_FLOW
	else:
		selected_animtree_type = GDACTION_TYPES.ACTION

func _disable_animtree_tools() -> void:	
	add_chaining_button.disabled = true	
	add_controlflow_button.disabled = true	
	add_action_button.disabled = true	
	delete_gd_button.disabled = true

func _set_animtree_tools() -> void:
	add_chaining_button.disabled = true
	add_controlflow_button.disabled = true
	add_action_button.disabled = true
	_set_moving_buttons_disabled(true)
	delete_gd_button.disabled = true
	if selected_animtree_type == GDACTION_TYPES.ROOT:
		return
	add_chaining_button.disabled = false 
	add_controlflow_button.disabled = false 
	add_action_button.disabled = false 
	_set_moving_buttons_disabled(false)
	var selected_parent: String = animtree_structure[selected_animtree]["parent"]
	if animtree_structure[selected_parent]["children"].size() == 1:
		return
	delete_gd_button.disabled = false

func _set_moving_buttons_disabled(disabled: bool) -> void:
	move_up_button.disabled = disabled
	move_down_button.disabled  = disabled

func _set_ui_to_gd_type() -> void:
	tool_options_button.hide()
	match selected_animtree_type:
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
	var property_type: int = anim_file.property_type
	interface_toggle(property_type_interfaces, property_type)
	property_options_button.select(property_type)
	match property_type:
		UIAnimationConstants.PROPERTY_TYPES.DELAY:
			pass
		UIAnimationConstants.PROPERTY_TYPES.SPEED:
			pass
		UIAnimationConstants.PROPERTY_TYPES.CURVE:
			pass
		UIAnimationConstants.PROPERTY_TYPES.EASE:
			_update_ease()

func _update_ease() -> void:
	var easing_value: float = anim_file.easing_value
	ease_curve_visualiser.change_curve_value(easing_value)
	
	easing_value_slider.value = easing_value
	_update_selected_easing_preset(easing_value)

func _update_selected_easing_preset(value: float) -> void:
	var easing_presets: PackedFloat32Array = UIAnimationConstants.EASING_PRESETS.values()
	if value in easing_presets:
		easing_presets_button.select(easing_presets.find(value))
	elif anim_file.easing_value == -1:
		easing_presets_button.select(0)
	else:
		easing_presets_button.select(-1)


# ANIMATION TREE STRUCTURE
## Manipulation
func _update_animtree_indexes(parent: String) -> void:
	var old_index: int = animtree_structure[editing_selected]["index"]
	var new_index: int = _determine_new_index(false)
	if new_index < old_index:
		_reorder_higher_indexes(parent, old_index, true)
		_reorder_higher_indexes(parent, new_index - 1)
	else:
		_reorder_higher_indexes(parent, new_index)
		_reorder_higher_indexes(parent, old_index, true)
	animtree_structure[editing_selected]["index"] = new_index

func _remove_animtree_child_from_parent(parent: String) -> void:
	var parent_children: PackedStringArray = animtree_structure[parent]["children"]
	var remove_name_index: int = parent_children.find(editing_selected)
	parent_children.remove_at(remove_name_index)
	animtree_structure[parent]["children"] = parent_children
	var remove_index: int = animtree_structure[editing_selected]["index"]
	_reorder_higher_indexes(parent, remove_index, true)

func _add_animtree_child_to_parent(parent: String, no_other_children: bool = false) -> void:
	if not no_other_children:
		_add_to_children_indexes(parent)
	_add_name_to_parent_children(parent)
	animtree_structure[editing_selected]["parent"] = parent

func _add_to_children_indexes(parent: String) -> void:
	var new_index: int = _determine_new_index()
	_reorder_higher_indexes(parent, new_index - 1)
	animtree_structure[editing_selected]["index"] = new_index

func _determine_new_index(add: bool = true) -> int:
	var selected_index: int = animtree_structure[selected_animtree]["index"]
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

func _add_name_to_parent_children(parent: String) -> void:
	var new_children: PackedStringArray = animtree_structure[parent]["children"]
	var new_child: String = parent + "/" + animtree_structure[editing_selected]["name"]
	selected_animtree = new_child
	new_children.append(new_child)
	animtree_structure[parent]["children"] = new_children

func _update_animtree_name(remove: bool = false) -> void:
	if not remove:
		animtree_structure[selected_animtree] = animtree_structure[editing_selected]
	animtree_structure.erase(editing_selected)

func _reorder_higher_indexes(selected_parent: String, index: int, decrease: bool = false) -> void:
	var children: PackedStringArray = animtree_structure[selected_parent]["children"]
	for child in children:
		var child_index: int = animtree_structure[child]["index"] 
		if child_index <= index:
			continue

		var change: int
		if decrease:
			change = -1
		else:
			change = 1
		animtree_structure[child]["index"] = child_index + change

## Editing
func _save_edit() -> void:
	editing = false
	_save_anim_file()
	update()

### Creation
func _create_animtree_name(creation_parent: String, creation_type: int, only_child: bool = false) -> void:
	var new_animtree_name: String
	var new_animtree_path: String
	var new_animtree_data: Dictionary
	match creation_type:
		GDACTION_TYPES.CHAINING:
			new_animtree_name = chaining_names[0]
			new_animtree_data = UIAnimationConstants.DEFAULT_CHAINING.duplicate()
		GDACTION_TYPES.CONTROL_FLOW:
			new_animtree_name = control_flow_names[0]
			new_animtree_data = UIAnimationConstants.DEFAULT_CONTROL_FLOW.duplicate()
		GDACTION_TYPES.ACTION:
			print("sha")
			new_animtree_name = action_names[0]
			print(new_animtree_name)
			new_animtree_data = UIAnimationConstants.DEFAULT_ACTION.duplicate()
	new_animtree_path = creation_parent + "/" + new_animtree_name
	new_animtree_data["parent"] = creation_parent
	animtree_structure[new_animtree_path] = new_animtree_data
	editing_selected = new_animtree_path
	_add_animtree_child_to_parent(creation_parent, only_child)
	if creation_type == GDACTION_TYPES.CHAINING:
		_create_animtree_name(new_animtree_path, GDACTION_TYPES.ACTION, true)

func _add_animtree_item() -> void:
	var selected_parent: String = animtree_structure[selected_animtree]["parent"]
	_create_animtree_name(selected_parent, create_animtree_type)
	_save_edit()

func _delete_animtree_item() -> void:
	_delete_animtree()
	_save_edit()

func _delete_animtree(is_child: bool = false) -> void:
	var old_selected: String = selected_animtree
	if animtree_structure[selected_animtree]["name"] in chaining_names:
		for child_path in animtree_structure[selected_animtree]["children"]:
			selected_animtree = child_path
			_delete_animtree(true)
	selected_animtree = old_selected
	editing_selected = selected_animtree
	if not is_child:
		var editing_parent: String = animtree_structure[editing_selected]["parent"]
		_remove_animtree_child_from_parent(editing_parent)
	_update_animtree_name(true)

### Moving
#### Detection
func _detect_valid_move() -> void:
	instructions_label.add_theme_color_override("font_color", Color.WHITE)
	instructions_label.text = "Move GDAction"
	confirm_reparent_button.disabled = false 
	
	if selected_animtree_type == GDACTION_TYPES.ROOT:
		_invalid_move("Cannot Be The Root")
		return
	var moving_name = animtree_structure[editing_selected]["name"]
	if _is_invalid_move():
		_invalid_move("Cannot Be The Same")
		return
	if moving_name in chaining_names:
		var selected_parent: String = animtree_structure[selected_animtree]["parent"]
		var editing_parent: String = animtree_structure[editing_selected]["parent"]
		if selected_parent != editing_parent:
			_invalid_move("Cannot Reparent a Chaining Action")
			return

func _invalid_move(reason: String) -> void:
	instructions_label.add_theme_color_override("font_color", Color.ORANGE)
	instructions_label.text = reason
	confirm_reparent_button.disabled = true

func _is_invalid_move() -> bool:
	if editing_selected == selected_animtree:
		return true
	var editing_parent: String = animtree_structure[editing_selected]["parent"]
	var editing_siblings: PackedStringArray = animtree_structure[editing_parent]["children"]
	var sibling_selected: bool = selected_animtree in editing_siblings
	if not sibling_selected:
		return false
	
	var moving_index: int = animtree_structure[editing_selected]["index"] 
	var selected_animtree_index: int = animtree_structure[selected_animtree]["index"]
	if moving_up:
			if moving_index == selected_animtree_index - 1:
				return true
	else:
			if moving_index == selected_animtree_index + 1:
				return true
	
	return false

#### Execution
func _move_animtree_item() -> void:
	var selected_parent: String = animtree_structure[selected_animtree]["parent"]
	var editing_parent: String = animtree_structure[editing_selected]["parent"]
	var same_parent: bool = selected_parent == editing_parent
	if same_parent: 
		_update_animtree_indexes(selected_parent)
	else:
		_remove_animtree_child_from_parent(editing_parent)
		_add_animtree_child_to_parent(selected_parent)
		_update_animtree_name()
	_save_edit()


# UI INTERACTION
## Animation Tree
func _on_animation_tree_item_selected():
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
	editing_selected = animtree_all_items.find_key(animtree.get_selected())
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
	_move_animtree_item()
	_normal_ui()	

func _on_cancel_move_button_pressed():	
	_normal_ui()	

### Create Tools
func _on_add_action_button_pressed():
	create_animtree_type = GDACTION_TYPES.ACTION
	_add_animtree_item()

func _on_add_controlflow_button_pressed():
	create_animtree_type = GDACTION_TYPES.CONTROL_FLOW
	_add_animtree_item()

func _on_add_chaining_button_pressed():
	create_animtree_type = GDACTION_TYPES.CHAINING
	_add_animtree_item()

func _on_delete_gd_button_pressed():
	_delete_animtree_item()

## Action Selected
func _on_tool_options_button_item_selected(index):
	update()

### Property Types
func _on_property_options_button_item_selected(index):
	anim_file.property_type = index
	_save_anim_file()
	update()

#### Ease
func _change_slider_zero_value(value: float) -> float:
	if value == 0:
		if anim_file.easing_value < 0:
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
	
	anim_file.easing_value = changed_val
	_save_anim_file()
	update()

func _on_easing_presets_button_item_selected(index):
	var preset_name: String = easing_presets_button.get_item_text(index)
	anim_file.easing_value = UIAnimationConstants.EASING_PRESETS[preset_name]
	_save_anim_file()
	update()

