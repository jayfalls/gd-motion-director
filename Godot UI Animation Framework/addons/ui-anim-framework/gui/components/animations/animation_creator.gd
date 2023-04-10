@tool
extends UIAnimationInterface


# VARIABLES
## References
var file_explorer: UIAnimationInterface

## Children
@onready var current_selected_label: Label = $%CurrentSelectedLabel
@onready var animation_tools_interface: HBoxContainer = $%AnimationToolsInterface
@onready var instructions_interface: VBoxContainer = $%InstructionsInterface
### Animation Tree
@onready var animtree: Tree = $%AnimationTree
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

## UI Information
const constant_name_arrays: PackedStringArray = [
	"chaining_names",
	"control_flow_names",
	"actions_names",
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
var actions_names: PackedStringArray
@onready var action_icon: CompressedTexture2D = preload("res://addons/ui-anim-framework/gui/icons/gdaction/actions/action_icon.png")
var property_types_names: PackedStringArray

## Temp Values
### Animation File
var saving: bool = false
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
	anim_file = ResourceLoader.load(current_anim)

func _save_anim_file() -> void:
	saving = true
	ResourceSaver.save(anim_file, current_anim)
	saving = false


# POPULATE UI
func _populate_interface() -> void:
	_detect_selected_anim()
	while detecting_selected:
		pass
	if not anim_changed:
		populated.emit()
		populating = false
		return
	
	while saving:
		pass
	populating = true
	if current_anim == "":
		anim_file == null
	else:
		_load_anim_file()
	tool_options_button.select(0)
	anim_changed = false
	animtree_changed = true
	selected_animtree = "."	
	populated.emit()
	populating = false

func _detect_selected_anim() -> void:
	detecting_selected = true
	var selected_anim = file_explorer.selected_anim
	if selected_anim == current_anim:
		detecting_selected = false
		return
	
	anim_changed = true
	current_anim = selected_anim
	current_anim_name = file_explorer.selected_anim_name
	if current_anim == "":
		current_selected_label.add_theme_color_override("font_color", Color.ORANGE)
		current_selected_label.text = "None"
	else:
		current_selected_label.add_theme_color_override("font_color", Color.GREEN)
		current_selected_label.text = current_anim_name
	
	detecting_selected = false

# UI UPDATES
func _update_interface() -> void:
	await populated
	if current_anim == "":
		animation_tools_interface.hide()
		return
	
	if animtree_changed and not filling_tree:
		_update_animtree()
	
	_determine_selected_type()

	interface_toggle(properties_interfaces, 0)
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

	for dummy in dummy_children:
		dummy.free()

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


# Animation Tree Structure
func _update_animtree_structure() -> void:
	pass

func _add_animtree_item(parent: String, type: GDACTION_TYPES, index: int = -1) -> void:
	pass

func _move_animtree_item(direction: int, new_parent: String = "") -> void:
	pass

func _delete_animtree_item() -> void:
	pass


# UI INTERACTION
## Animation Tree
func _on_animation_tree_item_selected():
	update()

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
