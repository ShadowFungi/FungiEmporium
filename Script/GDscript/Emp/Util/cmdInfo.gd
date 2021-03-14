extends Reference

class_name CommandInfo


var SporesNum : Spore_Count

var sendeeData : Sender_Data

var Command : String

var Whisper : bool


func _init(SprNum, SndrDat, cmd, Whspr):
	
	SporesNum = SprNum
	
	sendeeData = SndrDat
	
	Command = cmd
	
	Whisper = Whspr
