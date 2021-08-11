extends Node2D


onready var viewport = get_node("/root")

var Res = Vector2(318, 496)


func _ready():
	
	viewport.set_size_override(true, Vector2(318, 496))
	
	viewport.set_size_override_stretch(true)
