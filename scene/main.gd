extends Node2D

const PLAYER = preload("res://scene/player/player.tscn")

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var player_point: Marker2D = $PlayerPoint


func _ready() -> void:
	Game.on_game_start.connect(on_game_start)


func on_game_start() -> void:
	canvas_layer.show()
	
	var tween = create_tween()
	tween.tween_property(get_parent().color_rect,"modulate:a", 0.0, 0.5)
	tween.tween_callback(func ():
		get_parent().color_rect.hide()
		)
	
	
	var play_instance = PLAYER.instantiate()
	play_instance.global_position = player_point.global_position
	add_child(play_instance)
