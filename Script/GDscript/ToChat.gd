extends Button


export var Scene = ""


func _on_ToChatButton_pressed():
	
	get_tree().change_scene(Scene)
	

