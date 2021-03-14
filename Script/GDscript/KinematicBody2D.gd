extends KinematicBody2D


var Gravity = 150

var Speed = 150

var JumpSpeed = Gravity / 10


const GRAVITY = 100.0

const WALK_SPEED = 100.0


var velocity = Vector2()

func _physics_process(delta):
	
	velocity.y += delta * GRAVITY / 2

	if Input.is_action_pressed("ui_left"):
		
		velocity.x = -WALK_SPEED
		
	elif Input.is_action_pressed("ui_right"):
		
		velocity.x =  WALK_SPEED
		
	elif Input.is_action_pressed("ui_up"):
		
		velocity.y = -JumpSpeed
		
	elif Input.is_action_pressed("ui_down"):
		
		velocity.y = JumpSpeed
		

	# We don't need to multiply velocity by delta because "move_and_slide" already takes delta time into account.

	# The second parameter of "move_and_slide" is the normal pointing up.
	# In the case of a 2D platformer, in Godot, upward is negative y, which translates to -1 as a normal.
	
	move_and_slide(velocity, Vector2(0, -1))
	
	
