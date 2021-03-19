extends Reference

class_name Command_Info


var SporesNum : SporeCount

var sendeeData : SendData

var Command : String

var Whisper : bool


func _init(SprNum, SndrDat, cmd, Whspr):
	
	SporesNum = SprNum
	
	sendeeData = SndrDat
	
	Command = cmd
	
	Whisper = Whspr
