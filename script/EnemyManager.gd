extends Node
# 敌人管理

var enemies = [] #敌人数量数组
var current_level_data : LevelData
var timer = Timer.new() # 刷怪计时器

signal on_enemy_death() # 怪物死亡信号


func _ready() -> void:
	timer.one_shot = false
	timer.timeout.connect(on_time_out)
	add_child(timer)
	LevelManager.on_level_changed.connect(on_level_changed)


# 刷怪
func on_level_changed(level_data: LevelData) -> void:
	current_level_data = level_data
	timer.start(level_data.tick)


func on_time_out() -> void:
	if current_level_data:
		current_level_data.create_enemy()


# 检测剩余怪物数量
func check_enemies() -> void:
	if enemies.size() == 0:
		LevelManager.new_level()
