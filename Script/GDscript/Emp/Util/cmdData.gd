extends Reference

class_name Command_Data


var FuncRf : FuncRef

var SporesCount : Spore_Count

var PermissionLevel : int

var MaxArgs : int

var MinArgs : int

var Where : int


func _init(fRef : FuncRef, SprCnt : Spore_Count, PermLvl : int, MxArgs : int, MnArgs : int, Whr : int):
	
	FuncRf = fRef
	
	SporesCount = SprCnt
	
	PermissionLevel = PermLvl
	
	MaxArgs = MxArgs
	
	MinArgs = MnArgs
	
	Where = Whr
