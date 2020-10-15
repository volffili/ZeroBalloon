extends Item
class_name ItemWater

func click():
	main.set_max_health()
	if OS.get_name() == "Android":
		main.google.unlock_achievement("CgkIwrfiwb4EEAIQBA")
	.click()
	
func apply(num):
	return num
	
func is_clickable():
	return false
