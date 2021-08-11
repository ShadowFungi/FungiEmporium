extends Button

class_name Loaded


onready var BotEdit = get_node("/root/Overlay/BotNameContainer/BotName")

onready var ChannelEdit = get_node("/root/Overlay/ChannelContainer/ChannelToJoin")

onready var OauthEdit = get_node("/root/Overlay/TokenContainer/OauthToken")

onready var SavePrefix = "user://json/Saves/"


func _on_Load_Button_pressed():
	
	var file = File.new()
	
	if file.file_exists("EmporiumSave.json"):
	
		var Error = file.open("EmporiumSave.json", file.READ)
		
		if Error == OK:
		
			file.open("EmporiumSave.json", File.READ)

			var BotText = file.get_as_text()

			BotEdit.set_text(BotText)

			file.close()
		
			return

