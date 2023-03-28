@tool
extends UIAnimationInterface


# VARIABLES
## References
var file_explorer: UIAnimationInterface

## Children
@onready var current_selected_label: Label = $%CurrentSelectedLabel
@onready var animation_tools_interface: HBoxContainer = $%AnimationToolsInterface
@onready var instructions_interface: VBoxContainer = $%InstructionsInterface
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

## Temp Values
### Animation File
var saving: bool = false
var anim_file: UIAnimation
var current_anim: String = "" # Path to the anim file
var current_anim_name: String
var detecting_selected: bool = false
var anim_changed: bool = false


# INITIALISATION
func _ready_inject() -> void:
	await get_tree().process_frame
	
	
	interface_toggle(properties_interfaces, 0)
	
	# Property Types Interface
	property_options_button.clear()
	for type in UIAnimationConstants.PROPERTY_TYPES:
		property_options_button.add_item(type)
	easing_presets_button.clear()
	for preset in UIAnimationConstants.EASING_PRESETS.keys():
		easing_presets_button.add_item(preset)
	interface_toggle(property_type_interfaces, 0)


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
	
	animation_tools_interface.show()
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
		1:
			pass
		2:
			pass
		3:
			pass
		4:
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

# UI INTERACTION
func _on_tool_options_button_item_selected(index):
	update()

## Property Types
func _on_property_options_button_item_selected(index):
	anim_file.property_type = index
	_save_anim_file()
	update()

### Ease
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
