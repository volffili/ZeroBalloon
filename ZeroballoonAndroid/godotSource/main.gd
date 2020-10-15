extends Spatial

onready var anim_player = get_node("./CameraTarget/Camera/AnimationPlayer")
onready var camera_target = get_node("./CameraTarget")
onready var cam = get_node("./CameraTarget/Camera")
onready var balloon = get_node("./Balloon")
onready var balloon_mesh = get_node("./Balloon/Balloon/BalloonMesh")
onready var balloon_number = get_node("./Balloon/Number")
onready var water = get_node("./Water")
onready var gui = get_node("./Control")
onready var menu_music = get_node("./MenuMusic")
onready var game_music1 = get_node("./GameMusic1")
onready var game_music2 = get_node("./GameMusic2")
onready var debug = get_node("./DEBUG")
onready var water_pos = water.translation
onready var water_spectral = Vector3(0,0,0)

var next_hue = 0
var health = 10;
var max_health = 10;
var prefabs = {}
var items = []
var difficulty = 1
var state = 'intro'
var water_level = 0
var rot = 0
var rot_interpolation = 0
var last_rot = Vector3(0,0,0)
var wait = 0
var highscore = 0
var water_is_saving = false
var shuffle = 0
var water_helpers = 0
var die_soon = false
var die_prog = 0

var leaderboard_shown = false
var google = null


func set_max_health():
	water_is_saving = true

func load_game():
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		return
	save_game.open("user://savegame.save", File.READ)
	highscore = int(save_game.get_line())
	gui.set_highscore(highscore)
	
func save_game():
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	save_game.store_line(str(highscore))
	save_game.close()

func kill(item):
	shuffle = 1
	balloon.set_number(item.apply(balloon.number))
	items.erase(item)
	item.queue_free()
	
	var flag = false;
	for item in items:
		if item.is_clickable():
			flag = true
	
	die_soon = !flag and balloon.number != 0
	
	
	if balloon.number == 0:
		state = 'won'
		cam.shake(0.5,100,0.05)
	elif items.size() == 0:
		state = 'lost'
		cam.shake(0.5,100,0.05)
	
	

func _ready():
	prefabs["operator"] = load("res://items/itemoperator.tscn")
	prefabs["water"] = load("res://items/itemwater.tscn")
	
	load_game()
	
	if OS.get_name() == "Android":
		if(Engine.has_singleton("GooglePlay")):
			google = Engine.get_singleton("GooglePlay");
			google.init(get_instance_id())
			google.login()
			google.loadScore()
	
	
func shuffle_items():
	var shuffled = [] 
	var index_list = range(items.size())
	for i in range(items.size()):
		var x = randi()%index_list.size()
		shuffled.append(items[index_list[x]])
		index_list.remove(x)
	items = shuffled
	
func generate():
	items = []
	balloon.set_number(0)
	randomize()
				
	var items_count = 1
	var max_gen_num = 1;
	match(difficulty):
		1:
			max_gen_num = 7
			items_count = 2
			water_helpers = 0
		2:
			max_gen_num = 9
			items_count = 2
			water_helpers = 0
		3:
			max_gen_num = 5
			items_count = 3
			water_helpers = 0
		5:
			max_gen_num = 7
			items_count = 3
			water_helpers = 0
		6:
			max_gen_num = 9
			items_count = 3
			water_helpers = 0
		9:
			max_gen_num = 3
			items_count = 4
			water_helpers = 1
		10:
			max_gen_num = 5
			items_count = 4
			water_helpers = 1
		11:
			max_gen_num = 7
			items_count = 4
			water_helpers = 1
		12:
			max_gen_num = 9
			items_count = 4
			water_helpers = 1
		13:
			max_gen_num = 3
			items_count = 5
			water_helpers = 2
		14:
			max_gen_num = 5
			items_count = 5
			water_helpers = 2
		15:
			max_gen_num = 7
			items_count = 5
			water_helpers = 2
		16:
			max_gen_num = 9
			items_count = 5
			water_helpers = 2
		_:
			max_gen_num = 3+difficulty%7
			items_count = difficulty/7+4
			water_helpers = difficulty/7+1
			
	var division_generated = false;
	for i in range(items_count):
		var new_item = prefabs["operator"].instance()
		new_item.set_destination(balloon_number.translation)
		add_child(new_item)
		items.append(new_item)
		new_item.gen_op(max_gen_num)
		if(new_item.text[0] == '÷'):
			division_generated = true
			
		if(!division_generated && i == items_count-1):
			new_item.gen_div_num(max_gen_num)
		
		if new_item is ItemOperator:
			balloon.set_number(new_item.apply_inverse(balloon.number))
			if balloon.number == 0:
				free_items()
				generate()
				return
			
	for i in range(water_helpers):
		var ite = prefabs["water"].instance()
		ite.set_destination(balloon_number.translation)
		add_child(ite)
		items.append(ite)
		
	shuffle_items()
	balloon.set_start_num(balloon.number)
	
	
func intro(delta):
	pass
	
	
func _process(delta):
	match state:
		'intro':
			intro(delta)
		'menu':
			menu(delta)
		'won':
			won(delta)
		'game': 
			game(delta)
		'lost': 
			lost(delta)
		'wait_to_game':
			wait_to_game(delta)
		'rotate_right':
			rotate_right(delta)
		'next_level': 
			next_level(delta)
	water_level = (1-health/max_health)/2.7
	
	water.set_translation(water_pos+Vector3(0,water_level,0)+water_spectral)	

func camera_rotate():
	anim_player.play()

func free_items():
	for item in items:
		item.queue_free()
	items = []

func rotate_right(delta):
	if rot_interpolation < 1:
		rot_interpolation += delta	
		camera_target.rotation_degrees = last_rot.cubic_interpolate(Vector3(0,last_rot.y+90,0),Vector3(0,360,0),Vector3(0,-270,0),rot_interpolation) 
	else:
		var yrot = int(floor((last_rot.y+90)/90))*90;
		camera_target.rotation_degrees = Vector3(0,yrot%360,0)
		state = "next_level"
		
func lost(delta):
	
	if difficulty > highscore:
		highscore = difficulty
		gui.set_highscore(highscore)
		save_game()

	if OS.get_name() == "Android":
		if(!leaderboard_shown):
			leaderboard_shown = true
			google.submit_leaderboard(highscore, "CgkIwrfiwb4EEAIQAw")
		
	free_items()
	balloon.set_text("LOSS")
	difficulty = 1
	health *= pow(0.2,delta)  
	if(health < 0.5):
		leaderboard_shown = false
		last_rot = camera_target.rotation_degrees
		health = 0.5
		rot_interpolation = 0
		anim_player.play("goto_menu")
		state = "menu"
		game_music1.stop()
		game_music2.stop()
		menu_music.play()

func menu(delta):
	if health >= max_health:
		health = max_health
		gui.show()
		balloon.set_text("")
		
	else: 
		health *= pow(2,delta) 

func won(delta):
	free_items()
	balloon.set_text("WIN")
	difficulty += 1
	rot_interpolation = 0
	last_rot = camera_target.rotation_degrees
	state = "rotate_right"

func next_level(delta):
	balloon.set_text("LEVEL "+str(difficulty))
	if health >= max_health:
		health = max_health
		state = 'wait_to_game'
		wait = 1.0
	else: 
		if health <= 0:
			health = 0.1
		health *= pow(2.5,delta) 
		
func wait_to_game(delta):
	balloon.return_to_start_pos(delta)
	wait -= delta
	if wait < -0.6:
		wait = 0.0
		generate()
		state = "game"
		
func game(delta):
	rot += delta
	
	if die_soon:
		die_prog += delta
		if die_prog > 1:
			die_prog = 0
			die_soon = false
			cam.shake(0.5,100,0.05)
			state = "lost"
	
	if shuffle > 0:
		shuffle -= delta*5
	else:
		shuffle = 0
	
	for i in range(items.size()):
		var rot_i = rot+i*2*PI/items.size(); 
		items[i].scale = Vector3(1-shuffle,1-shuffle,1-shuffle)
		items[i].set_translation(Vector3(cos(rot_i)*0.5*(1-shuffle),water_level+0.35,sin(rot_i)*0.5*(1-shuffle)))
		
	if water_is_saving:	
		health += delta*25
		if health > max_health:
			health = max_health
			water_is_saving = false
	else:
		health -= delta*0.6
		if health <= -balloon.ypos*2.7*max_health:
			health = 0.1
			cam.shake(0.5,100,0.05)
			state = 'lost'
	
