extends Reference
class_name amazon_Price

var peanut : String

var item : String

var tag : Dictionary

func _init(nut : String, itm : String, tagDiction : Dictionary):
	
	peanut = nut
	
	tag = tagDiction

	item = itm
