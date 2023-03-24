@tool
extends UIAnimationInterface


# VARIABLES
## References
var interface: EditorSelection
var controller: UIAnimationController

## Children
### No Controller
@onready var controller_none_detected_interface: VBoxContainer = $%NoneDetectedInterface
### Has Controller
@onready var controller_detected_interface: MarginContainer = $%DetectedInterface
@onready var selected_scene_tool: OptionButton = $%SceneToolOptions
#### Groups & Nodes Interface
@onready var groups_interface: MarginContainer = $%GroupsInterface
##### Groups
@onready var groups_list: ItemList = $%GroupsList
@onready var groups_rename_button: Button = $%GroupsRenameButton
@onready var groups_delete_button: Button = $%GroupsDeleteButton
##### Nodes
@onready var nodes_list: ItemList = $%NodesList
@onready var add_node_button: Button = $%AddNodeButton
@onready var add_node_name_label: Label = $%AddNodeNameLabel
@onready var node_renamed_to_label: Label = $%NodeRenamedLabel
@onready var nodes_select_up_button: Button = $%NodesSelectUpButton
@onready var nodes_select_down_button: Button = $%NodesSelectDownButton
@onready var rename_node_button: Button = $%NodesRenameButton
@onready var delete_node_button: Button = $%NodesDeleteButton
#### Events Interface
@onready var events_interface: MarginContainer = $%EventsInterface
#### Triggers Interface
@onready var triggers_interface: MarginContainer = $%TriggersInterface

## Constants
const controller_name: String = "UIAnimationController"
### Interface Groups
const scene_tool_main_interfaces: PackedStringArray = [
	"controller_none_detected_interface",
	"controller_detected_interface"
]
const scene_tool_options_interfaces: PackedStringArray = [
	"groups_interface",
	"events_interface",
	"triggers_interface"
]

## Editor Data
var edited_scene_root: Node
var selected_editor_node: Node

## Realtime
### Groups & Nodes
var selected_group: String
var selected_group_nodes: Array[NodePath]
var selected_node_path: NodePath
var node_list_index: int


# POPULATE UI
func _populate_interface() -> void:
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
	_populate_groups_list()
	_populate_nodes_list()

func _populate_groups_list() -> void:
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

func _populate_nodes_list() -> void:
	nodes_list.clear()
	update_selected_group_nodes()
	if not selected_group_nodes.is_empty():
		var names: PackedStringArray
		for node_path in selected_group_nodes:
			names.append(controller.unique_nodes[node_path])
		for n in names:
			nodes_list.add_item(n)


# UI UPDATES
func _update_interface() -> void:
	_get_editor_information()
	if not _has_controller():
		interface_toggle(scene_tool_main_interfaces, 0)
		return
	
	interface_toggle(scene_tool_main_interfaces, 1)
	_update_groups_ui()
	_update_nodes_ui()

func _get_editor_information() -> void:
	edited_scene_root = get_tree().edited_scene_root
	var selected_editor_nodes: Array[Node]
	if is_instance_valid(interface):
		selected_editor_nodes = interface.get_selected_nodes()
	if selected_editor_nodes.is_empty():
		selected_editor_node = null
	else:
		selected_editor_node = selected_editor_nodes[0]
		selected_node_path = _editor_path_to_run_path(selected_editor_node.get_path())

## Groups List
func _update_groups_ui() -> void:
	if controller.groups.size() > 0:
		groups_rename_button.disabled = false
		groups_delete_button.disabled = false
	else:
		groups_rename_button.disabled = true
		groups_delete_button.disabled = true
	

## Nodes List
func _update_nodes_ui() -> void:
	_update_node_list()
	_update_manipulate_nodes_buttons()

func _update_node_list() -> void:
	if nodes_list.is_anything_selected():
		return
	if selected_editor_node == null:
		return
	if selected_node_path in selected_group_nodes:
		var index: int = selected_group_nodes.find(selected_node_path)
		nodes_list.select(index)
		node_list_index = index

func _update_manipulate_nodes_buttons() -> void:
	if selected_group_nodes.size() > 1:
		nodes_select_up_button.disabled = false
		nodes_select_down_button.disabled = false
	else:
		nodes_select_up_button.disabled = true
		nodes_select_down_button.disabled = true
	
	add_node_button.disabled = true
	rename_node_button.disabled = true
	delete_node_button.disabled = true
	node_renamed_to_label.hide()
	
	if controller.groups.is_empty():
		add_node_name_label.add_theme_color_override("font_color",Color.RED)
		add_node_name_label.text = "Create a group first"
	elif selected_editor_node == null:
		add_node_name_label.add_theme_color_override("font_color",Color.RED)
		add_node_name_label.text = "No node selected"
	elif selected_node_path in selected_group_nodes:
		add_node_name_label.add_theme_color_override("font_color",Color.ORANGE)
		add_node_name_label.text = "Node is already in this group"
		if controller.unique_nodes[selected_node_path] != selected_editor_node.name:
			node_renamed_to_label.show()
			node_renamed_to_label.text = "Node Renamed To: " + controller.unique_nodes[selected_node_path]
	else:
		add_node_name_label.add_theme_color_override("font_color",Color.GREEN)
		add_node_name_label.text = selected_editor_node.name
		add_node_button.disabled = false
	
	if nodes_list.is_anything_selected():
		rename_node_button.disabled = false
		delete_node_button.disabled = false


# EDITOR INFORMATION
func _has_controller() -> bool:
	if not is_instance_valid(edited_scene_root):
		return false
	var children: Array[Node] = edited_scene_root.get_children()
	for child in children:
		if "is_ui_anim" in child:
			child.edited_scene_root = edited_scene_root
			if controller == child:
				return true
			else:
				controller = child
				return true
	return false

func _editor_path_to_run_path(path: NodePath) -> NodePath:
	var path_string: String = path
	var root_name: String = edited_scene_root.name
	var editor_path_index: int = path_string.find(root_name)
	path_string = path_string.substr(editor_path_index)
	if edited_scene_root.name + "/" in path_string:
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
## None Detected Interface
func _on_none_detected_create_button_pressed():
	if not is_instance_valid(edited_scene_root):
		return
	var node: UIAnimationController = UIAnimationController.new()
	node.name = controller_name
	edited_scene_root.add_child(node)
	node.set_owner(edited_scene_root)
	
	repopulate.emit()

## Detected Interface
func _on_scene_tool_options_item_selected(index):
	interface_toggle(scene_tool_options_interfaces, index)
	repopulate.emit()

### Groups Interface
#### Groups List
func _add_group(text: String) -> void:
	controller.groups.append(text)
	repopulate.emit()

func _rename_group(text: String) -> void:
	controller.rename_group(selected_group, text)
	repopulate.emit()

func _delete_group() -> void:
	controller.remove_group(selected_group)
	repopulate.emit()

func _on_groups_list_item_clicked(_index, _at_position, _mouse_button_index):
	repopulate.emit()

func _on_groups_add_button_pressed():
	var description: String = "Add a Group"
	main_panel.line_edit_popup(self._add_group, description, controller.groups)

func _on_groups_rename_button_pressed():
	var description: String = "Choose a New Name for the " + selected_group + " Group"
	main_panel.line_edit_popup(self._rename_group, description, controller.groups)

func _on_groups_delete_button_pressed():
	var description: String = "Are you sure you want to delete the " + selected_group + " group?"
	main_panel.yes_no_popup(self._delete_group, description)

#### Nodes List
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
	_update_interface()

func _rename_node(text: String) -> void:
	controller.rename_node(selected_group_nodes[node_list_index], text)
	repopulate.emit()

func _delete_node() -> void:
	selected_group_nodes.pop_at(node_list_index)
	controller.grouped_nodes[selected_group] = selected_group_nodes.duplicate()
	repopulate.emit()

func _on_nodes_select_up_button_pressed():
	_switch_nodes_selection(true)

func _on_nodes_select_down_button_pressed():
	_switch_nodes_selection()

func _on_nodes_rename_button_pressed():
	var description: String = "Choose a New Name for the " + str(selected_group_nodes[node_list_index]) + " Node"
	main_panel.line_edit_popup(self._rename_node, description)

func _on_nodes_delete_button_pressed():
	var description: String = "Are you sure you want to delete the " + nodes_list.get_item_text(node_list_index) + " node?"
	main_panel.yes_no_popup(self._delete_node, description)

func _on_add_node_button_pressed():
	var selected_name: String = selected_editor_node.name
	selected_group_nodes.append(selected_node_path)
	controller.grouped_nodes[selected_group] = selected_group_nodes.duplicate()
	if not selected_node_path in controller.unique_nodes.keys():
		controller.unique_nodes[selected_node_path] = selected_name
	
	repopulate.emit()
