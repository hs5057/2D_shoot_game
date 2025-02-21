extends Node
# 管理关卡

const FILE_PATH = "res://resource/level/"

# 简单的定义关卡数据
var level_data : Array[LevelData] = []


var current_level = 0 # 当前关卡

signal on_level_changed(level_data: LevelData) # 关卡改变后的信号


func _ready() -> void:
	var files = DirAccess.get_files_at("res://resource/level/")
	for file_name in files:
		level_data.append(load(FILE_PATH + file_name))


# 下一关
func new_level() -> void:
	current_level += 1
	on_level_changed.emit(level_data[current_level - 1])


# 回合结束 停止刷怪
func stop() -> void:
	EnemyManager.timer.stop() # 关闭刷怪计时器
