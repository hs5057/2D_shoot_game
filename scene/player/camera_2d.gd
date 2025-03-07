extends Camera2D


func _ready() -> void:
	_init_limit()
	pass


func _init_limit() -> void:
	var map_land = Game.map.land as TileMapLayer
	var rect = map_land.get_used_rect()
	var left_top_point = map_land.map_to_local(Vector2(rect.position.x,rect.position.y)) - Vector2(8,8)
	var temp = len(map_land.get_used_cells())
	var temp2 = map_land.get_used_cells()[temp-1]
	var right_bottom_point = map_land.map_to_local(temp2) + Vector2(8,8)
	limit_left = left_top_point.x
	limit_top = left_top_point.y
	limit_right = right_bottom_point.x
	limit_bottom = right_bottom_point.y
