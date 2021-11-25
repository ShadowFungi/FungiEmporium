extends Button


export var Scene = ""


func _pressed():
	
	get_tree().change_scene(Scene)
	

