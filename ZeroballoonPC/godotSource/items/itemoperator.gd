extends Item
class_name ItemOperator   
	
onready var label = get_node("Viewport/Label")
onready var sprite = get_node("./Sprite")
onready var balloon = get_node("/root/Main/Balloon")
onready var text_material = sprite.get_surface_material(0)
var text
var num

func gen_op(max_num):
	var op = "/----".substr(randi()%5,1)
	num = randi()%(max_num-2)+2
	text = op+str(num)
	label.set_text(text)

func gen_div_num(n):
	var op = "/"
	num = n
	text = op+str(num)
	label.set_text(text)
	
func set_text(t):
	num = int(t.substr(1,t.length()-1))
	text = t
	label.set_text(text)
	
func div_produces_remainder():
	return balloon.number % num and text[0] == '/'
	

func is_clickable():
	return !div_produces_remainder()	

func click():
	if div_produces_remainder():
		return	
	.click()
	
func _process(delta):
	if div_produces_remainder():
		text_material.albedo_color = Color.from_hsv(1,0,0.3)
	else:
		text_material.albedo_color = Color.from_hsv(1,0,1)

func apply_inverse(total):
	if text[0] == '+':
		return total-num
	if text[0] == '-':
		return total+num
	if text[0] == '/':
		return total*num
		
		
func apply(total):
	if text[0] == '+':
		return total+num
	if text[0] == '-':
		return total-num
	if text[0] == '/':
		return total/num
