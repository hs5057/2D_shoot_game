extends Resource
class_name EnemyData

signal on_death() # 死亡通知
signal on_hit(damage) # 受击通知

# 敌人属性
@export var damage : int = 5 # 伤害值
@export var max_hp : int = 10 # 最大生命值

var current_hp: # 敌人当前生命值
	set(_value):
		if current_hp and current_hp - _value != 0:
			on_hit.emit(current_hp - _value)
		current_hp = max(_value, 0)
		if current_hp <= 0:
			on_death.emit()


func _init() -> void:
	current_hp = max_hp
