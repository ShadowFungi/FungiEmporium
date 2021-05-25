extends RigidBody2D

var thrust = Vector2(1, 0)


func _integrate_forces(state):
	
	if Input.is_action_pressed("ui_right"):
		pass
