extends Reference

class_name CommandData


var FuncRf : FuncRef

var SporesCount : SporeCount

var PermissionLevel : int

var MaxArgs : int

var MinArgs : int

var Where : int


func _init(fRef : FuncRef, SprCnt : SporeCount, PermLvl : int, MxArgs : int, MnArgs : int, Whr : int):
	
	FuncRf = fRef
	
	SporesCount = SprCnt
	
	PermissionLevel = PermLvl
	
	MaxArgs = MxArgs
	
	MinArgs = MnArgs
	
	Where = Whr
