extends Label

var google = null

func _ready():
	return
	if OS.get_name() == "Android":
		if(Engine.has_singleton("GooglePlay")):
			set_text("module exists")
			google = Engine.get_singleton("GooglePlay");
			google.init(get_instance_id())
			google.login()
		
