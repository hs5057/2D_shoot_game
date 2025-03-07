extends CanvasLayer

var is_pause: bool = false


func _ready() -> void:
	%ButtonResume.pressed.connect(_on_button_resume_pressed)
	%ButtonQuit.pressed.connect(_on_button_quit_pressed)


func _on_button_resume_pressed() -> void:
	set_pause()


func _on_button_quit_pressed() -> void:
	get_tree().quit()


func set_pause() -> void:
	if is_pause:
		self.hide()
		get_tree().paused = false
		is_pause = false
		call_deferred("queue_free")
	else:
		self.show()
		get_tree().paused = true
		is_pause = true


#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("pause"):
		#set_pause()
