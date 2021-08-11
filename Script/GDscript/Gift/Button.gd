extends Button

func _pressed():
	$"../../Gift".chat(get_parent().get_text())
	get_parent().set_text("")
