extends Button


func _pressed():
	var Bot = get_node("VBoxContainer/BotName")
	
	var config = ConfigFile.new()
	config.set_value("bot_info" + Bot.get_name(), Bot.get_name(), Bot.get_text())
	config.save("user://SecuredAuth.cfg")
