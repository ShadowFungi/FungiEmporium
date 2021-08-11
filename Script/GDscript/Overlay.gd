extends Control


func _ready():
	
	get_tree().get_root().set_transparent_background(false)
	
	get_tree().set_screen_stretch(1, 1, Vector2(320, 180))
