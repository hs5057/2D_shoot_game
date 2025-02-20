extends Node2D
class_name BaseBullet

@export var speed : float = 500 # 子弹速度
@export var dir : Vector2 = Vector2.ZERO # 子弹飞行向量


func _ready() -> void:
	look_at(get_global_mouse_position())


func _physics_process(delta: float) -> void:
	global_position += dir * delta * speed
