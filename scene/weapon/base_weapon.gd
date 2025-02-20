extends Node2D
class_name BaseWeapon

const _pre_bullet = preload("res://scene/bullet/base_bullet.tscn")

@export var weapon_name : String = "默认武器"
@export var bullet_max : int = 30 # 子弹最大数量
@export var damage : int = 5 # 子弹伤害
@export var weapon_rof : float = 0.2 # 射击速度

var current_bullet_count : int = 0 # 当前子弹数量
var current_rof_tick = 0

@onready var bullet_point: Node2D = $BulletPoint
@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	current_bullet_count = bullet_max
	PlayerManager.on_weapon_changed.emit(self)
	PlayerManager.on_bullet_count_changed.emit(current_bullet_count,bullet_max)


# 射击
func shoot() -> void:
	var instance = _pre_bullet.instantiate()
	instance.global_position = bullet_point.global_position
	instance.dir = global_position.direction_to(get_global_mouse_position())
	get_tree().root.add_child(instance)
	
	current_bullet_count -= 1
	PlayerManager.on_bullet_count_changed.emit(current_bullet_count,bullet_max)
	
	if current_bullet_count <= 0:
		reload()


# 更换弹匣
func reload() -> void:
	PlayerManager.on_weapon_reload.emit()
	await get_tree().create_timer(2.0).timeout # 临时模拟换弹匣需要的时间
	current_bullet_count = bullet_max
	PlayerManager.on_bullet_count_changed.emit(current_bullet_count,bullet_max)


func _process(delta: float) -> void:
	current_rof_tick += delta
	if Input.is_action_pressed("fire") and current_rof_tick >= weapon_rof and current_bullet_count > 0:
		shoot()
		current_rof_tick = 0
	
