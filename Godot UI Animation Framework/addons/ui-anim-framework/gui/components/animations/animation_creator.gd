@tool
extends UIAnimationInterface


# VARIABLES
## References
var file_explorer: UIAnimationInterface

## Children
@onready var current_selected_label: Label = $%CurrentSelectedLabel
@onready var animation_tools: TabContainer = $%AnimationTools
### Easing
@onready var ease_curve_visualiser: EaseCurveVisualiser = $%EaseCurveVisualiser
@onready var easing_controls: VBoxContainer = $%EasingControls
@onready var easing_enabled_check: CheckBox = $%EasingEnabledCheck
@onready var easing_value_slider: HSlider = $%EasingValueSlider
@onready var easing_presets_button: OptionButton = $%EasingPresetsButton

## Temp Values
var anim_file: UIAnimation
var current_anim: String = ""
var current_anim_name: String
var anim_changed: bool = false


# INITIALISATION
func _ready_inject() -> void:
	easing_presets_button.clear()
	for preset in UIAnimation.EASING_PRESETS.keys():
		easing_presets_button.add_item(preset)


# ANIM FILE
func _load_anim_file() -> void:
	anim_file = ResourceLoader.load(current_anim)


# POPULATE UI
func _populate_interface() -> void:
	_detect_selected_anim()
	if not anim_changed:
		populated.emit()
		populating = false
		return
	
	populating = true
	_load_anim_file()
	populated.emit()
	populating = false

func _detect_selected_anim() -> void:
	var selected_anim = file_explorer.selected_anim
	if selected_anim == current_anim:
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


# UI UPDATES
func _update_interface() -> void:
	await populated
	if current_anim == "":
		animation_tools.hide()
		return
	
	animation_tools.show()
	_update_ease_ui()

func _update_ease_ui() -> void:
	if not anim_file.easing:
		easing_enabled_check.button_pressed = false
		ease_curve_visualiser.change_curve_value(0)
		easing_controls.hide()
		return
	
	easing_enabled_check.button_pressed = true
	easing_controls.show()
	var easing_value: float = anim_file.easing_value
	ease_curve_visualiser.change_curve_value(easing_value)
	
	easing_value_slider.value = anim_file.easing_value
	var easing_presets: PackedFloat32Array = anim_file.EASING_PRESETS.values()
	if easing_value in easing_presets:
		easing_presets_button.select(easing_presets.find(easing_value))
	elif anim_file.easing_value == -1:
		easing_presets_button.select(0)
	else:
		easing_presets_button.select(-1)


# UI INTERCATION
## Ease
func _on_easing_enabled_check_toggled(button_pressed):
	anim_file.easing = button_pressed
	update()

func _on_easing_value_slider_value_changed(value):
	var changed_val : float = snapped(value, 0.1)
	if changed_val == 0:
		if anim_file.easing_value < 0:
			changed_val -= 0.2
		else:
			changed_val += 0.2
	
	anim_file.easing_value = snapped(changed_val, 0.1)
	update()

func _on_easing_presets_button_item_selected(index):
	var preset_name: String = easing_presets_button.get_item_text(index)
	anim_file.easing_value = anim_file.EASING_PRESETS[preset_name]
	update()
