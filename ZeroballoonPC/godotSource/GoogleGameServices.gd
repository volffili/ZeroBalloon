extends Node

var module = null

func _ready():
	if(Engine.has_singleton("MyGoogleServicesModule")):
		print("module exists")
		module = Engine.get_singleton("MyGoogleServicesModule")
			

func _process(delta):
	if module:
		print(module.myFirstFunction("Filip"))
