extends RigidBody2D

var Speed = Vector2(10, 0)

var JumpHeight = Vector2(0, 10)


func _integrate_forces(state):
	
	
	if Input.is_action_pressed("ui_right"):
		
		set_linear_velocity(Speed)
		
		print(get_linear_velocity())
	
	
	if Input.is_action_pressed("ui_left"):
		
		set_linear_velocity(-Speed)
		
		print(get_linear_velocity())
		
	if Input.is_action_pressed("ui_up"):
		
		set_applied_force(JumpHeight)
		
		print(get_linear_velocity().y)
