@tool
extends Button


signal settings_toggle


# VARIABLES
## Icons
@onready var settings_icon: CompressedTexture2D = preload("res://addons/ui-anim-framework/gui/icons/settings_icon.png")
@onready var exit_icon: CompressedTexture2D = preload("res://addons/ui-anim-framework/gui/icons/exit_icon.png")

## States
var is_exit: bool = false

# INITIALISATION
func _ready():
	icon = settings_icon
	self.pressed.connect(_toggle_button)


# OPERATION
func _toggle_button() -> void:
	settings_toggle.emit()
	if is_exit:
		is_exit = false
		icon = settings_icon
	else:
		is_exit = true
		icon = exit_icon
