extends Spatial

onready var label = get_node("./MainNumberViewport/MainNumberLabel")
onready var meshLabel = get_node("./Number")

var number = 1
var start_num = 1
var height = 0.2
var new_height = 0.2
var progress = 1
onready var start_pos = translation
var delta_acc = 0
var ypos = 0
var ret_to_start

func return_to_start_pos(delta):
	ret_to_start = true;
	ypos *= pow(0.1,delta)
	translation = start_pos+Vector3(0,ypos,0)

func set_start_num(num):
	ret_to_start = false
	start_num = num
	new_height = height
	set_number(number)
	progress = 1
	delta_acc = 0
	
func set_number(num):
	number=num
	set_text(str(number))
	height = new_height
	new_height = float(number)/start_num/10*2
	progress = 0

func set_text(text):
	label.set_text(text)
	
func _process(delta):
	if(ret_to_start):
		return
		
	if progress < 1:
		progress += delta
	else:
		progress = 1
	
	var display_height = height * (1-progress) +  new_height * progress
	
	
	if display_height < 0.17:
		delta_acc += delta*4
		display_height += sin(delta_acc)*0.015
	
	ypos = min(1,max(0,0.2-display_height))
	translation = start_pos+Vector3(0,ypos,0)
