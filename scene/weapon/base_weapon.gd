extends Node2D
class_name BaseWeapon

const PRE_BULLET = preload("res://scene/bullet/base_bullet.tscn")
const RELOAD_AUDIO = [preload("res://audio/wpn_reload_start.mp3"),preload("res://audio/wpn_reload_end.mp3")]

@export var weapon_name : String = "默认武器"
@export var weapon_index : int = 1
@export var bullet_max : int = 30 # 子弹最大数量
@export var damage : int = 5 # 子弹伤害
@export var weapon_rof : float = 0.2 # 射击速度
@export var reload_time : float = 2.0 # 换弹时间

var current_bullet_count : int = 0 # 当前子弹数量
var current_rof_tick = 0
var player: Player # 属于某个玩家

@onready var bullet_point: Node2D = $BulletPoint
@onready var sprite: Sprite2D = $Sprite2D
@onready var fire_particles: GPUParticles2D = $GPUParticles2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var audio_reload: AudioStreamPlayer2D = $AudioStreamPlayer2D2


func _ready() -> void:
	fire_particles.lifetime = weapon_rof - 0.01
	# 如果之前记录过换枪之前的弹药数，则切换回来后，恢复成之前的弹药数
	if weapon_index == 1:
		if PlayerManager.first_weapon_bullet_count:
			current_bullet_count = PlayerManager.first_weapon_bullet_count
		else:
			current_bullet_count = bullet_max
	elif weapon_index == 2:
		if PlayerManager.second_weapon_bullet_count:
			current_bullet_count = PlayerManager.second_weapon_bullet_count
		else:
			current_bullet_count = bullet_max

	PlayerManager.on_weapon_changed.emit(self)
	Game.current_weapon = self
	PlayerManager.on_bullet_count_changed.emit(current_bullet_count,bullet_max)


# 射击
func shoot() -> void:
	var bullet_instance = PRE_BULLET.instantiate()
	bullet_instance.global_position = bullet_point.global_position
	bullet_instance.dir = global_position.direction_to(get_global_mouse_position())
	bullet_instance.current_weapon = self
	Game.map.bullet_node.add_child(bullet_instance)
	
	current_bullet_count -= 1
	PlayerManager.on_bullet_count_changed.emit(current_bullet_count,bullet_max)
	
	if current_bullet_count <= 0:
		reload()
		
	weapon_anim()
	

func weapon_anim() -> void:
	fire_particles.restart()
	var tween = create_tween().set_ease(Tween.EASE_IN)
	tween.tween_property(sprite, "scale:x", 0.7, weapon_rof / 2 )
	tween.tween_property(sprite, "scale:x", 1.0, weapon_rof / 2 )
	
	audio_player.play()
	
	Game.camera_offset(Vector2(-0.5, 1),weapon_rof)


# 更换弹匣
func reload() -> void:
	audio_reload.stream = RELOAD_AUDIO[0]
	audio_reload.play()
	PlayerManager.on_weapon_reload.emit()
	await get_tree().create_timer(reload_time - 0.42).timeout
	audio_reload.stream = RELOAD_AUDIO[1]
	audio_reload.play()
	
	await get_tree().create_timer(0.42).timeout
	current_bullet_count = bullet_max
	PlayerManager.on_weapon_reload_completed.emit()
	PlayerManager.on_bullet_count_changed.emit(current_bullet_count,bullet_max)
	


func _process(delta: float) -> void:
	current_rof_tick += delta
	if Input.is_action_pressed("fire") and current_rof_tick >= weapon_rof and current_bullet_count > 0:
		shoot()
		current_rof_tick = 0
	
