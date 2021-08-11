extends Camera2D


func _ready():
	
	set_custom_viewport(get_parent())
	
	clear_current()
	
	make_current()
	
	print(is_current())
	
	
