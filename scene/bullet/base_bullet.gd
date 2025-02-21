extends Node2D
class_name BaseBullet

const HIT_EFFECT = preload("res://scene/hit_effect.tscn")

@export var speed : float = 1000 # 子弹速度
@export var dir : Vector2 = Vector2.ZERO # 子弹飞行向量

var current_weapon: BaseWeapon # 属于某个武器
var _tick = 0


func _ready() -> void:
	look_at(get_global_mouse_position())


func _physics_process(delta: float) -> void:
	global_position += dir * delta * speed
	_tick += delta
	if Engine.get_physics_frames() % 20:
		if _tick >= 3:
			queue_free()

#func _process(delta: float) -> void:
	#global_position += dir * delta * speed


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is BaseEnemy:
		Game.damage(Game.player , body)
		set_physics_process(false)
		var hit_effect_instance = HIT_EFFECT.instantiate()
		Game.map.add_child(hit_effect_instance)
		hit_effect_instance.global_position = global_position
		queue_free()
