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
		enemy_instance.y_sort_enabled = true
		current_count += 1


# 获取刷怪区域中的随机点
#func get_random_point() -> Vector2:
	#var map_land = Game.map.land as TileMapLayer
	#var rect = map_land.get_used_rect()
	#
	#var spawn_point = map_land.map_to_local(Vector2(
			#randf_range(rect.position.x,rect.position.x + rect.size.x), 
			#randf_range(rect.position.y,rect.position.y + rect.size.y)))
	#test()
	#return spawn_point
	
#func get_random_point1() -> Vector2:
	#var ran = RandomNumberGenerator.new()
	#var map_land = Game.map.land as TileMapLayer
	#var num = ran.randi_range(0, len(map_land.get_used_cells()))
	#var local_position = map_land.map_to_local(map_land.get_used_cells()[num])
	#return local_position

func get_random_point() -> Vector2:
	# 先找到TileMapLayer的左上角坐标，和右下角坐标，
	# 然后在左下和右下的基础都往中间缩小一个瓦片的大小作为生成敌人坐标的范围
	var _ran = RandomNumberGenerator.new()
	var _map_land = Game.map.land as TileMapLayer
	var _rect = _map_land.get_used_rect()
	var _left_top_point = _map_land.map_to_local(Vector2(_rect.position.x,_rect.position.y)) + Vector2(16,16)
	var _temp = len(_map_land.get_used_cells())
	var _temp2 = _map_land.get_used_cells()[_temp - 1]
	var _right_bottom_point = _map_land.map_to_local(_temp2) - Vector2(16,16)
	var _x = _ran.randi_range(_left_top_point.x,_right_bottom_point.x)
	var _y = _ran.randi_range(_left_top_point.y,_right_bottom_point.y)
	#print(_x,",",_y)
	return Vector2(_x,_y)
