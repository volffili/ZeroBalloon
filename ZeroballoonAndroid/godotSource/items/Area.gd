extends Area

onready var item = get_owner()

func _ready():
	pass

func _on_Area_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			item.click()
