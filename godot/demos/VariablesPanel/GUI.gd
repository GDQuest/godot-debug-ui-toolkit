tool
extends PanelContainer
# This is an example editor tool for creating dynamic variable controls using the provided theme.


# Use this variable to set the number of variable controls
export(int, 0, 10) var controls := 1 setget set_controls

const VariableControl := preload("res://demos/VariablesPanel/VariableControl.tscn")

onready var variable_controls := $MarginContainer/VBoxContainer/VariableControls
onready var edited_scene_root := get_tree().edited_scene_root


func _ready() -> void:
	for idx in range(controls):
		if idx < variable_controls.get_child_count():
			continue
		
		var control := VariableControl.instance()
		variable_controls.add_child(control)
		control.owner = edited_scene_root


func set_controls(new_controls: int) -> void:
	if not is_inside_tree(): yield(self, 'ready')
	
	if controls < new_controls:
		for idx in range(new_controls):
			if idx < variable_controls.get_child_count():
				continue
			
			var control := VariableControl.instance()
			variable_controls.add_child(control)
			control.owner = edited_scene_root
	else:
		for idx in range(new_controls, controls):
			var child := variable_controls.get_child(idx)
			if child: child.queue_free()
	
	controls = new_controls
