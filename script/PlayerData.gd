extends Resource
class_name PlayerData

# 玩家属性
@export var damage : int = 5 # 伤害值
@export var max_hp : int = 10 # 最大生命值

var current_hp: # 玩家当前生命值
	set(_value):
		current_hp = max(_value, 0)
		PlayerManager.on_player_hp_changed.emit(_value,max_hp)
		if _value <= 0:
			PlayerManager.on_player_death.emit()

# 玩家存档
@export var gold : int = 0 # 玩家持有金币

 
func _init() -> void:
	current_hp = max_hp
