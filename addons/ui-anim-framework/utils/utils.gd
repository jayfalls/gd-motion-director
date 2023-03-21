@tool
class_name UIAnimFrameworkUtils


static func get_plugin() -> EditorPlugin:
	var tree: SceneTree = Engine.get_main_loop()
	return tree.get_root().get_child(0).get_node_or_null("UIAnimFrameworkPlugin")


static func get_editor_scale() -> float:
	var plugin := get_plugin()
	if plugin:
		return plugin.get_editor_interface().get_editor_scale()
	return 1.0
