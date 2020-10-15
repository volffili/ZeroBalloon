extends AudioStreamPlayer

onready var menu_music = load("res://menu.ogg")
onready var game_music = load("res://game.ogg")

func start_menu_music():
	stop()
	stream = menu_music;
	play()

func play_game_music():
	stop()
	stream = game_music;
	play()
