@tool
class_name UIAnimationPanel extends Control


# VARIABLES
## References
var interface: EditorSelection
var controller: UIAnimationController

## Children
@onready var popup_panel: UIAnimationPopupPanel = $PopupPanel
### Scene Tool
@onready var scene_tool_none_detected_interface: VBoxContainer = $%NoneDetectedInterface
@onready var scene_tool_detected_interface: MarginContainer = $%DetectedInterface
#### Scene Tool Interface
@onready var selected_scene_tool: OptionButton = $%SceneToolOptions
##### Groups Interface
@onready var scene_tool_groups_interface: MarginContainer = $%SceneToolGroupsInterface
@onready var groups_list: ItemList = $%GroupsList
@onready var nodes_list: ItemList = $%NodesList
@onready var add_node_button: Button = $%AddNodeButton
@onready var add_node_name_label: Label = $%AddNodeNameLabel
@onready var rename_node_button: Button = $%NodesRenameButton
@onready var delete_node_button: Button = $%NodesDeleteButton
##### Events Interface
@onready var scene_tool_events_interface: MarginContainer = $%SceneToolEventsInterface
##### Triggers Interface
@onready var scene_tool_triggers_interface: MarginContainer = $%SceneToolTriggersInterface

## Constants
const controller_name: String = "UIAnimationController"
## Interface Groups
#### Scene Tool
const scene_tool_main_interfaces: PackedStringArray = [
	"scene_tool_none_detected_interface",
	"scene_tool_detected_interface"
]
const scene_tool_options_interfaces: PackedStringArray = [
	"scene_tool_groups_interface",
	"scene_tool_events_interface",
	"scene_tool_triggers_interface"
]

## Editor Data
var scene_root: Node
var selected_editor_node: Node

## Realtime
### Popup
var popup_callable: Callable
### Groups
var selected_group: String
var selected_group_nodes: Array[NodePath]
var node_list_index: int


# INITIALISATION
func _ready():
	_populate_ui()
	interface.selection_changed.connect(_populate_ui)
	_update_ui()
	interface.selection_changed.connect(_update_ui)


# LOADING VARIABLES
func _populate_ui() -> void:
	_populate_scene_tool_interface()
	_update_ui()

## Scene Tool Interface
func _populate_scene_tool_interface() -> void:
	# Check if scene tool can and needs to be repopulated
	if not _has_controller():
		return
	
	match selected_scene_tool.selected:
		0:
			_populate_groups_scene_tool()
		1:
			pass
		2:
			pass

func _populate_groups_scene_tool() -> void:
	# Groups List
	var selected_group_index: int = 0
	if groups_list.item_count > 0:
		selected_group_index = groups_list.get_selected_items()[0]
	groups_list.clear()
	if not controller.groups.is_empty():
		for group in controller.groups:
			groups_list.add_item(group)
		if selected_group_index + 1 > groups_list.get_item_count():
			selected_group_index = 0
		groups_list.select(selected_group_index)
		selected_group = controller.groups[selected_group_index]
	else:
		selected_group = ""
	
	# Nodes List
	nodes_list.clear()
	update_selected_group_nodes()
	if not selected_group_nodes.is_empty():
		var names: PackedStringArray
		for node_path in selected_group_nodes:
			names.append(controller.unique_nodes[node_path])
		for n in names:
			nodes_list.add_item(n)


# UI UPDATES
func _update_ui() -> void:
	scene_root = get_tree().edited_scene_root
	var selected_editor_nodes: Array[Node]
	if is_instance_valid(interface):
		selected_editor_nodes = interface.get_selected_nodes()
	if selected_editor_nodes.is_empty():
		selected_editor_node = null
	else:
		selected_editor_node = selected_editor_nodes[0]
	_update_scene_tool_interface()

## Toggle between interfaces
func interface_toggle(group: PackedStringArray, index: int) -> void:
	if self[group[index]].visible:
		return
	for variable_ref in group:
		self[variable_ref].hide()
	self[group[index]].show()

## Scene Tool Interface
func _update_scene_tool_interface() -> void:
	if not _has_controller():
		interface_toggle(scene_tool_main_interfaces, 0)
		return
	
	# Scene Tool Groups Interface
	interface_toggle(scene_tool_main_interfaces, 1)
	_update_nodes_ui()

func _update_nodes_ui() -> void:
	_update_node_list()
	_update_manipulate_nodes_buttons()

func _update_node_list() -> void:
	if nodes_list.is_anything_selected():
		return
	if selected_editor_node == null:
		return
	var path: NodePath = _editor_path_to_run_path(selected_editor_node.get_path())
	if path in selected_group_nodes:
		var index: int = selected_group_nodes.find(path)
		nodes_list.select(index)
		node_list_index = index

func _update_manipulate_nodes_buttons() -> void:
	add_node_button.disabled = true
	rename_node_button.disabled = true
	delete_node_button.disabled = true
	if controller.groups.is_empty():
		add_node_name_label.add_theme_color_override("font_color",Color.RED)
		add_node_name_label.text = "Create a group first"
	elif selected_editor_node == null:
		add_node_name_label.add_theme_color_override("font_color",Color.RED)
		add_node_name_label.text = "No node selected"
	elif _editor_path_to_run_path(selected_editor_node.get_path()) in selected_group_nodes:
		add_node_name_label.add_theme_color_override("font_color",Color.ORANGE)
		add_node_name_label.text = "Node is already in this group"
	else:
		add_node_name_label.add_theme_color_override("font_color",Color.GREEN)
		add_node_name_label.text = selected_editor_node.name
		add_node_button.disabled = false
	
	if nodes_list.is_anything_selected():
		rename_node_button.disabled = false
		delete_node_button.disabled = false


# EDITOR INFORMATION
func _has_controller() -> bool:
	if not is_instance_valid(scene_root):
		return false
	var children: Array[Node] = scene_root.get_children()
	for child in children:
		if "is_ui_anim" in child:
			if controller == child:
				return true
			else:
				controller = child
				return true
	return false

func _editor_path_to_run_path(path: NodePath) -> NodePath:
	var path_string: String = path
	var root_name: String = scene_root.name
	var editor_path_index: int = path_string.find(root_name)
	path_string = path_string.substr(editor_path_index)
	if scene_root.name + "/" in path_string:
		path_string = path_string.replace(root_name + "/","")
	else:
		path_string = path_string.replace(root_name, ".")
	return path_string


# INTERNAL VALUES
func update_selected_group_nodes() -> void:
	selected_group_nodes.clear()
	# Check if there are node paths to populate
	if selected_group == "":
		return
	if controller.grouped_nodes.is_empty():
		return
	if not selected_group in controller.grouped_nodes.keys():
		return
	selected_group_nodes = controller.grouped_nodes[selected_group].duplicate()


# UI INTERACTION
## Popup Interface
func _popup_closed() -> void:
	if popup_panel.le_confirmed.is_connected(popup_callable):
		popup_panel.le_confirmed.disconnect(popup_callable)
	elif popup_panel.yn_confirmed.is_connected(popup_callable):
		popup_panel.yn_confirmed.disconnect(popup_callable)
	
	_populate_ui()

## Scene Tool Interface
### None Detected Interface
func _on_none_detected_create_button_pressed():
	if not is_instance_valid(scene_root):
		return
	var node: UIAnimationController = UIAnimationController.new()
	node.name = controller_name
	scene_root.add_child(node)
	node.set_owner(scene_root)
	
	_populate_ui()

### Detected Interface
func _on_scene_tool_options_item_selected(index):
	interface_toggle(scene_tool_options_interfaces, index)
	_populate_ui()

#### Groups Interface
##### Groups List
func _add_group(text: String) -> void:
	controller.groups.append(text)
	_populate_ui()

func _rename_group(text: String) -> void:
	controller.rename_group(selected_group, text)
	_populate_ui()

func _delete_group() -> void:
	controller.remove_group(selected_group)
	_populate_ui()

func _on_groups_list_item_clicked(_index, _at_position, _mouse_button_index):
	_populate_ui()

func _on_groups_add_button_pressed():
	popup_panel.invalid_texts = controller.groups
	popup_callable = _add_group
	popup_panel.le_confirmed.connect(popup_callable, CONNECT_PERSIST)
	popup_panel.line_edit_popup_show("Add a Group")

func _on_groups_rename_button_pressed():
	popup_panel.invalid_texts = controller.groups
	popup_callable = _rename_group
	popup_panel.le_confirmed.connect(popup_callable, CONNECT_PERSIST)
	popup_panel.line_edit_popup_show("Choose a New Name for the " + selected_group + " Group")

func _on_groups_delete_button_pressed():
	popup_callable = _delete_group
	popup_panel.yn_confirmed.connect(popup_callable, CONNECT_PERSIST)
	popup_panel.yes_no_popup_show("Are you sure you want to delete the " + selected_group + " group?")

##### Nodes List
func _switch_nodes_selection(previous: bool = false) -> void:
	if not nodes_list.is_anything_selected():
		node_list_index = -1
	
	if previous:
		if node_list_index <= 0:
			node_list_index = nodes_list.item_count - 1
		else:
			node_list_index -= 1
	else:
		if node_list_index >= nodes_list.item_count - 1:
			node_list_index = 0
		else:
			node_list_index += 1
	
	nodes_list.select(node_list_index)
	_update_ui()

func _rename_node(text: String) -> void:
	controller.rename_node(selected_group_nodes[node_list_index], text)
	_populate_ui()

func _delete_node() -> void:
	selected_group_nodes.pop_at(node_list_index)
	controller.grouped_nodes[selected_group] = selected_group_nodes.duplicate()
	_populate_ui()

func _on_nodes_select_up_button_pressed():
	_switch_nodes_selection(true)

func _on_nodes_select_down_button_pressed():
	_switch_nodes_selection()

func _on_nodes_rename_button_pressed():
	popup_panel.invalid_texts = [""]
	popup_callable = _rename_node
	popup_panel.le_confirmed.connect(popup_callable, CONNECT_PERSIST)
	popup_panel.line_edit_popup_show("Choose a New Name for the " + str(selected_group_nodes[node_list_index]) + " Node")

func _on_nodes_delete_button_pressed():
	popup_callable = _delete_node
	popup_panel.yn_confirmed.connect(popup_callable, CONNECT_PERSIST)
	popup_panel.yes_no_popup_show("Are you sure you want to delete the " + nodes_list.get_item_text(node_list_index) + " node?")

func _on_add_node_button_pressed():
	var selected_name: String = selected_editor_node.name
	var path: NodePath = _editor_path_to_run_path(selected_editor_node.get_path())
	selected_group_nodes.append(path)
	controller.grouped_nodes[selected_group] = selected_group_nodes.duplicate()
	if not path in controller.unique_nodes.keys():
		controller.unique_nodes[path] = selected_name
	
	_populate_ui()
