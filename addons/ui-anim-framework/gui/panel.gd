@tool
class_name UIAnimationPanel extends Control


# VARIABLES
## References
var interface: EditorSelection

## Children
@onready var tab_container: TabContainer = $MarginContainer/TabContainer
@onready var popup_panel: UIAnimationPopupPanel = $PopupPanel
@onready var scene_tool_interface: UIAnimationInterface = $MarginContainer/TabContainer/SceneToolInterface
@onready var animations_interface: UIAnimationInterface = $MarginContainer/TabContainer/AnimationsInterface
@onready var settings_interface: UIAnimationInterface = $MarginContainer/SettingsInterface
@onready var settings_button: Button = $MarginContainer/MarginContainer/SettingsButton

## Constants
enum tabs {
	SCENE_TOOL,
	ANIMATIONS
}

## Realtime
### Popup
var popup_callable: Callable


# INITIALISATION
func _ready():
	_prepare_interfaces()
	update_ui()
	interface.selection_changed.connect(update_ui)

func _prepare_interfaces() -> void:
	tab_container.show()
	settings_interface.hide()
	
	# Settings Interface
	if not settings_button.settings_toggle.is_connected(_toggle_settings):
		settings_button.settings_toggle.connect(_toggle_settings, CONNECT_PERSIST)
	settings_interface.main_panel = self
	
	# Scene Tool Interface
	scene_tool_interface.main_panel = self
	scene_tool_interface.interface = interface
	
	# Animations Interface
	animations_interface.main_panel = self


# POPULATE/UPDATE UI
func _editor_scene_changed(node: Node):
	update_ui()

func update_ui() -> void:
	scene_tool_interface.update()
	animations_interface.update()
	if settings_button.is_exit:
		settings_interface.update()
	

func _toggle_settings() -> void:
	if settings_button.is_exit:
		tab_container.show()
		settings_interface.settings_exit()
	else:
		tab_container.hide()
		settings_interface.settings_show()
	update_ui()


# POPUPS
func _popup_closed() -> void:
	if popup_panel.le_confirmed.is_connected(popup_callable):
		popup_panel.le_confirmed.disconnect(popup_callable)
	elif popup_panel.yn_confirmed.is_connected(popup_callable):
		popup_panel.yn_confirmed.disconnect(popup_callable)
	
	update_ui()

func line_edit_popup(call: Callable, description: String, invalid_texts: PackedStringArray = [""]) -> void:
	popup_panel.invalid_texts = invalid_texts
	popup_callable = call
	popup_panel.le_confirmed.connect(popup_callable, CONNECT_PERSIST)
	popup_panel.line_edit_popup_show(description)

func yes_no_popup(call: Callable, description: String) -> void:
	popup_callable = call
	popup_panel.yn_confirmed.connect(popup_callable, CONNECT_PERSIST)
	popup_panel.yes_no_popup_show(description)


# SETTINGS
func _on_settings_interface_settings_updated():
	animations_interface.load_settings()


# UI INTERACTION
func _on_tab_container_tab_changed(_tab):
	# Ensure that the tab refreshes properly
	await get_tree().create_timer(0.01).timeout
	update_ui()
