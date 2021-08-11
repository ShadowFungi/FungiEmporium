extends Timer

class_name SporeCount

var sporeNum = 0

func _init():
	set_autostart(true)
	set_wait_time(15)


func _on_SporeTimer_timeout():
	randomize()
	if sporeNum >= 3000000:
		pass
	elif sporeNum < 3000000:
		sporeNum += rand_range(1, 500)
	print(floor(sporeNum))
	start()
