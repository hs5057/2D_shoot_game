extends Resource
class_name LevelData
# 关卡数据

@export var enemy_scene : PackedScene # 关卡敌人场景
@export var max_count : int # 关卡敌人数量
@export var tick : float # 刷怪间隔
@export var once_count : int # 单次数量

var current_count : int = 0


# 刷新敌人
func create_enemy() -> void:
	for i in once_count:
		if current_count >= max_count:
			LevelManager.stop()
			return
		var enemy_instance = enemy_scene.instantiate() as Node2D
		enemy_instance.global_position = get_random_point()
		Game.map.enemy_node.add_child(enemy_instance)
		current_count += 1


# 获取刷怪区域中的随机点
func get_random_point() -> Vector2:
	var map_land = Game.map.land as TileMapLayer
	var rect = map_land.get_used_rect()
	
	var spawn_point = map_land.map_to_local(Vector2i(
			randf_range(rect.position.x,rect.position.x + rect.size.x), 
			randf_range(rect.position.y,rect.position.y + rect.size.y)))
	
	return spawn_point
	
