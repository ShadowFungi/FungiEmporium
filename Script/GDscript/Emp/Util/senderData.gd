extends Reference

class_name Sender_Data


var Message : String

var User : String

var Channel : String

var Tags : Dictionary

func _init(Usr : String, Ch : String, TagDict : Dictionary):
	
	User = Usr
	
	Channel = Ch
	
	Tags = TagDict
