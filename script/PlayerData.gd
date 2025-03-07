extends Resource
class_name PlayerData

# 玩家属性

# 当前等级
var current_level = 1

# 基础伤害叠加
var basic_damage: int = 5

# 基础伤害倍率
var basic_damage_multiple: float = 1

# 暴击率
var critical_rate : float = 0.02

# 暴击伤害倍率
var critical_damage_multiple : float = 1.5

# 移动速度
var run_speed: float = 55.0

# 持有金币
var gold : int = 0:
	set(value):
		gold = max(value, 0)
		PlayerManager.glod_changed.emit(value)


# 拾取范围(半径px)
var pick_up_radius : float = 30.0

# 最大生命值
var max_hp : int = 30 

# 当前生命值
var current_hp: 
	set(_value):
		current_hp = max(_value, 0)
		PlayerManager.on_player_hp_changed.emit(_value,max_hp)
		if _value <= 0:
			PlayerManager.on_player_death.emit()

# 每秒恢复血量
var health_recovery_rate: float = 0.05

# 最大经验值
var max_experience = 5

# 当前经验值
var current_experience = 0:
	set(value):
		current_experience = value
		Game.current_experience = value

# 每次升级增加最大经验值上限
const TARGET_EXPERIENCE_GROWTH = 5

# 当前是否暴击
var is_critical : bool = false 


func init_hp() -> void:
	current_hp = max_hp
