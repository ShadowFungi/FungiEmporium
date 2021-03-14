extends Timer

class_name Spore_Count


var SporeNum = 0


func _init():
	
	set_autostart(true)
	
	set_wait_time(30)


func _on_SporeTimer_timeout():
	
	randomize()
	
	if SporeNum >= 30000000000:
		
		pass
	
	elif SporeNum < 30000000000:
		
		SporeNum += rand_range(1, 500)
	
	print(SporeNum)
	
	start()
