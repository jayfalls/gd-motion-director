@tool
class_name UIAnimationPanel extends Control


# VARIABLES
## References
var interface: EditorSelection

## Children
@onready var popup_panel: UIAnimationPopupPanel = $PopupPanel
@onready var scene_tool_interface: UIAnimationInterface = $MarginContainer/TabContainer/SceneToolInterface

## Realtime
### Popup
var popup_callable: Callable


# INITIALISATION
func _ready():
	_prepare_interfaces()
	_populate_ui()
	interface.selection_changed.connect(_populate_ui)

func _prepare_interfaces() -> void:
	# Scene Tool Interface
	scene_tool_interface.main_panel = self
	scene_tool_interface.interface = interface


# POPULATE UI
func _populate_ui() -> void:
	scene_tool_interface._populate_interface()
	_update_ui()


# UI UPDATES
func _update_ui() -> void:
	scene_tool_interface._update_interface()


# POPUPS
func _popup_closed() -> void:
	if popup_panel.le_confirmed.is_connected(popup_callable):
		popup_panel.le_confirmed.disconnect(popup_callable)
	elif popup_panel.yn_confirmed.is_connected(popup_callable):
		popup_panel.yn_confirmed.disconnect(popup_callable)
	
	_populate_ui()

func line_edit_popup(call: Callable, description: String, invalid_texts: PackedStringArray = [""]) -> void:
	popup_panel.invalid_texts = invalid_texts
	popup_callable = call
	popup_panel.le_confirmed.connect(popup_callable, CONNECT_PERSIST)
	popup_panel.line_edit_popup_show(description)

func yes_no_popup(call: Callable, description: String) -> void:
	popup_callable = call
	popup_panel.yn_confirmed.connect(popup_callable, CONNECT_PERSIST)
	popup_panel.yes_no_popup_show(description)
