extends Node2D

const PLAYER = preload("res://scene/player/player.tscn")

@onready var land: TileMapLayer = %Land
@onready var player_point: Marker2D = $PlayerPoint
@onready var left_top_point: Marker2D = %LeftTopPoint
@onready var right_bottom_point: Marker2D = %RightBottomPoint
@onready var enemy_node: Node2D = %EnemyNode
@onready var bullet_node: Node2D = %BulletNode
@onready var entity_node: Node2D = $EntityNode
@onready var items: Node2D = %Items
@onready var audio_player_component: AudioPlayerComponent = $AudioPlayerComponent


func _ready() -> void:
	Game.map = self
	Game.on_game_start.connect(on_game_start)


func on_game_start() -> void:
	audio_player_component.play_random(true, -30)
	LevelManager.new_level()
	# 场景过渡
	var tween = create_tween()
	tween.tween_property(get_parent().color_rect,"modulate:a", 0.0, 0.5)
	tween.tween_callback(func ():
		get_parent().color_rect.hide()
		)
	
	# 实例化玩家
	var play_instance = PLAYER.instantiate()
	play_instance.global_position = player_point.global_position
	entity_node.add_child(play_instance)
