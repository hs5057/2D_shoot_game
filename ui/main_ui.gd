extends Control

@onready var color_rect: ColorRect = %ColorRect
@onready var control: Control = $Control


func start_game() -> void:
	color_rect.show()
	var tween = create_tween()
	tween.tween_property(color_rect,"modulate:a", 1.0, 0.5).from(0.0)
	tween.tween_callback(func ():
		control.hide()
		Game.on_game_start.emit()
	)


func _on_start_button_pressed() -> void:
	start_game()


func _on_exit_button_pressed() -> void:
	get_tree().quit()
