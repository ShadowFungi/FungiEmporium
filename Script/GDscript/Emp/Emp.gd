tool
extends EditorPlugin

func _enter_tree() -> void:
	
	add_custom_type("Emp", "Node", load("res://Script/GDscript/EmpNode.gd"), preload("res://Images/Emp.png"))	

func _exit_tree() -> void:
	
	remove_custom_type("Emp")
	
