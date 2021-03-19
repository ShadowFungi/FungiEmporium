extends Node

onready var Connections = get_node("/root/Control/Connections/")

export(String) var JsonDir = "usr://ConnectionData.json"

var DefualtData = {
	
	"Bot" : {
		
		"UserName" : get_parent().get_text() ,
		
		"Oauth" : ""
		
	}
	
}


func _on_ChannelToJoin_text_entered(new_text):
	var text = 
	print text
