extends Control


onready var viewport = get_tree().get_root()

func _ready():
	
	viewport.set_size_override(true, Vector2(318, 496))
	
	OS.set_window_size(Vector2(318, 496))
	
	
