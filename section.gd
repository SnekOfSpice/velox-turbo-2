extends Node2D
class_name Section

var lines := []

signal section_finished()


func get_global_center() -> Vector2:
	if find_child("Center"):
		return find_child("Center").position
	push_warning("No Center defined")
	return Vector2.ZERO
