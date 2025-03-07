extends Control

const UPDATE_SCENE = preload("res://ui/update_scene/update_scene.tscn")
const MENU_CONTROL = preload("res://ui/menu_control.tscn")
const PAUSE_SCENE = preload("res://ui/pause_scene.tscn")

@onready var hud_layer: CanvasLayer = $HUDLayer
@onready var color_rect: ColorRect = %ColorRect
@onready var transition_layer: CanvasLayer = $TransitionLayer

var game_started: bool = false


func _ready() -> void:
	pass
	PlayerManager.level_up.connect(_on_level_up)
	
	# 开始菜单
	var menu_control_instance = MENU_CONTROL.instantiate()
	self.add_child(menu_control_instance)
	menu_control_instance.start_button.pressed.connect(func ():
		start_game()
		)
	menu_control_instance.exit_button.pressed.connect(func ():
		get_tree().quit()
		)
	Game.on_game_start.connect(func ():
		menu_control_instance.queue_free()
		)
	


func start_game() -> void:
	color_rect.show()
	var tween = create_tween()
	tween.tween_property(color_rect,"modulate:a", 1.0, 0.5).from(0.0)
	tween.tween_callback(func ():
		Game.on_game_start.emit()
		hud_layer.show()
		game_started = true
		remove_child(transition_layer)
	)


func _on_level_up(current_experience:float , target_experience:float , current_level:int) -> void:
	print("升级了")
	#Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	var update_scene_instance = UPDATE_SCENE.instantiate()
	get_tree().root.add_child(update_scene_instance)
	update_scene_instance.init()
	
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and game_started:
		var pause_scene_instance = PAUSE_SCENE.instantiate()
		self.add_child(pause_scene_instance)
		pause_scene_instance.set_pause()
