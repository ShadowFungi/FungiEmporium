extends RigidBody2D

var Impulse = float()

func _integrate_forces(state):
	
	
	
	if Input.is_action_pressed("ui_left"):
	
		randomize()
	
		if Impulse >= 5:
			
			Impulse.y += rand_range(1, 6)
			
			Impulse.x += rand_range(1, 6)
	
		var ImpulseF = Vector2(floor(Impulse), floor(Impulse) - rand_range(1 , 5))
	
		apply_impulse(ImpulseF, ImpulseF)


