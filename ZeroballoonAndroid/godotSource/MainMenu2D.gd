extends MarginContainer

onready var main = get_node("../../Main")
onready var anim_player = get_node("../CameraTarget/Camera/AnimationPlayer")
onready var camera_target = get_node("../CameraTarget")
onready var menu_music = get_node("../MenuMusic")
onready var game_music1 = get_node("../GameMusic1")
onready var game_music2 = get_node("../GameMusic2")
onready var hscore_label = get_node("./VBoxContainer/Score/Label")
onready var menu = get_node("./VBoxContainer")
onready var about_button = get_node("./VBoxContainer/Menu/About")
onready var about_info = get_node("./AbInfoCon")

var delta_progress = 0
var clicked = false
var first_time = true

func set_highscore(hscore):
	hscore_label.set_text(str(hscore))



func _on_Button_button_down():
	main.state = "intro2"
	anim_player.stop()
	menu_music.stop()
	
	if (randf() < 0.5):
		game_music1.play()
	else:
		game_music2.play()
	
	clicked = true
	delta_progress = 0
	
func _process(delta):
	if !clicked:
		return

	if first_time:
		camera_target.rotation *= pow(0.2,delta)  
		if camera_target.rotation.length() <= 0.075:
			camera_target.rotation = Vector3(0,0,0)
			anim_player.play("start_game")
			start_game()
			first_time = false
	else:
		anim_player.play("start_game_again")
		start_game()
		
func start_game():
	clicked = false
	hide()
	
	main.health = 10;
	main.max_health = 10;
	main.difficulty = 1
	main.water_level = 0
	main.wait = 0
	main.water_is_saving = false
	main.shuffle = 0
	main.water_helpers = 0
	main.die_soon = false
	main.die_prog = 0

	
	main.generate()
	main.state = "game"
	

func _on_Exit_button_down():
	get_tree().quit()

func _on_back_button_down():
		about_info.hide()
		menu.show()

func _on_About_button_down():
		about_info.show()
		menu.hide()

func _on_Cup_button_down():
	if OS.get_name() == "Android":
		main.google.show_leaderboard("CgkIwrfiwb4EEAIQAw")


func _on_Achievements_button_down():
	if OS.get_name() == "Android":
		main.google.show_achievements()
