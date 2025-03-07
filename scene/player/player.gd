extends CharacterBody2D
class_name Player

@onready var anim: AnimatedSprite2D = %AnimatedSprite2D
@onready var body: Node2D = $Body
@onready var weapon_node: Node2D = %WeaponNode
@onready var camera: Camera2D = $Camera2D
@onready var audio_player_component: AudioPlayerComponent = $AudioPlayerComponent
@onready var cross: Sprite2D = $cross
@onready var collision: CollisionShape2D = %CollisionShape2D

var speed : float = 55.0
var _current_anim : String = "down_"
var is_aiming_grenade: bool = false
var is_roll: bool =false

const GRENADE_PATH = preload("res://scene/grenade/grenade_path.tscn")

func _ready() -> void:
	$AudioListener2D.make_current()
	
	Game.player = self
	
	var first_weapon_instance = PlayerManager.first_weapon.instantiate()
	weapon_node.add_child(first_weapon_instance)
	
	PlayerManager.on_player_death.connect(
		func () -> void:
			weapon_node.hide()
			anim.play("death")
	)
	
	# 初始化拾取范围
	collision.shape.radius = PlayerManager.player_data.pick_up_radius


func _process(_delta: float) -> void:
	
	if PlayerManager.is_death():
		return
	
	if is_aiming_grenade:
		if cross:
			cross.show()
			cross.global_position = get_global_mouse_position()
	
	var dir: Vector2 = Vector2.ZERO
	
	dir.x = Input.get_axis("move_left" , "move_right")
	dir.y = Input.get_axis("move_up" , "move_down")
	
	velocity = dir.normalized() * PlayerManager.player_data.run_speed
	
	
	change_anim()
	
	move_and_slide()


func _input(event: InputEvent):
	if PlayerManager.is_death(): return
	
	# 右键按下开始瞄准
	if event.is_action_pressed("throw_grenade"):
		is_aiming_grenade = true
	
	# 右键释放投掷
	if event.is_action_released("throw_grenade") and is_aiming_grenade:
		cross.hide()
		is_aiming_grenade = false
		var grenade_instance = GRENADE_PATH.instantiate() as Path2D
		get_tree().get_first_node_in_group("EntityNodeLayer").add_child(grenade_instance)
		grenade_instance.path_over.connect(_on_path_over)
		grenade_instance.hit_target.connect(_on_hit_target)
		grenade_instance.global_position = global_position
		grenade_instance.set_path_tar_pos(get_global_mouse_position(),global_position)

	if event.is_action_pressed("roll"):
		is_roll = true
		_current_anim = get_movement_dir()
		anim.play(_current_anim + "roll")
		await anim.animation_finished
		is_roll = false



func _on_path_over() -> void:
	#print("_on_path_over")
	pass


func _on_hit_target() -> void:
	#print("_on_hit_target")
	pass


# 切换动画
func change_anim() -> void:
	if is_roll:
		return
	else:
		if velocity == Vector2.ZERO:
			anim.play(_current_anim + "idle")
		else:
			_current_anim = get_movement_dir()
			anim.play(_current_anim + "move")
	
	
	
	var _position = get_global_mouse_position()
	
	weapon_node.look_at(_position)
	
	if _position.x > position.x and body.scale.x != 1:
		body.scale.x = 1
	elif _position.x < position.x and body.scale.x != -1:
		body.scale.x = -1
		


# 获取方向
func get_movement_dir() -> String:
	weapon_node.z_index = 1
	if velocity == Vector2.ZERO:
		return "lr_"
	
	var angle = velocity.angle() # 获取速度向量的角度
	var degree = rad_to_deg(angle)
	
	if 45 <= degree and degree < 135:
		return "down_"
	elif -135 <= degree and degree < -45:
		weapon_node.z_index = 0
		return "up_"
	
	return "lr_"


func pick_up(_body:Node2D) -> void:
	print("pick_up")
