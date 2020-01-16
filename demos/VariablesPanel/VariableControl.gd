tool
extends VBoxContainer

signal value_changed(value)

export var min_value: = 0.0 setget set_min_value
export var max_value: = 100.0 setget set_max_value
export var value: = 0.0 setget set_value


onready var label: Label = $HBoxContainer/Label
onready var spin_box: SpinBox = $HBoxContainer/SpinBox
onready var slider: HSlider = $HSlider


func _ready() -> void:
	_set_label_text()
	connect("renamed", self, "_set_label_text")
	spin_box.connect("mouse_entered", spin_box.get_line_edit(), "grab_focus")
	spin_box.connect("mouse_exited", spin_box.get_line_edit(), "release_focus")
	spin_box.connect("value_changed", self, "set_value")
	slider.connect("value_changed", self, "set_value")


func set_min_value(new_min_value: float) -> void:
	if not is_inside_tree():
		yield(self, "ready")
	
	spin_box.min_value = new_min_value
	slider.min_value = new_min_value
	min_value = spin_box.min_value
	
	if is_equal_approx(min_value, new_min_value):
		value = min_value
		emit_signal("value_changed", value)


func set_max_value(new_max_value: float) -> void:
	if not is_inside_tree():
		yield(self, "ready")
	
	spin_box.max_value = new_max_value
	slider.max_value = new_max_value
	max_value = spin_box.max_value
	
	if is_equal_approx(max_value, new_max_value):
		value = max_value
		emit_signal("value_changed", value)


func set_value(new_value: float) -> void:
	if not is_inside_tree():
		yield(self, "ready")
	
	spin_box.value = new_value
	slider.value = new_value
	value = spin_box.value
	emit_signal("value_changed", value)


func _set_label_text() -> void:
	if not is_inside_tree():
		yield(self, "ready")
	label.text = name.capitalize()
