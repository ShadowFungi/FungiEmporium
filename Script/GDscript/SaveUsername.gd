extends Button


onready var SavePrefix = "user://Data/Saves/"

onready var SavePath = SavePrefix + "EmporiumBotName.json"


func _on_Username_Button_pressed():	
	
	var Dir = Directory.new()
	
	if !Dir.dir_exists(SavePrefix):
		
		Dir.make_dir_recursive(SavePrefix)
	
	var file = File.new()
	
	var Error = file.open(SavePath, File.WRITE)
	
	if Error == OK:
		
		file.store_var(get_parent().get_text())
		
		file.close()
		
		print(get_parent().get_text())
		
	else:
		
		print("ERR - Failed to save for some mysterious reason")
