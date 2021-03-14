extends Button

func _pressed():
	
	$"../Emp".Chat($"../LineEdit".text)
	
	$"../LineEdit".text = ""
