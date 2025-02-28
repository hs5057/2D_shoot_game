extends Node
# 玩家管理单例

var first_weapon = preload("res://scene/weapon/base_weapon.tscn")
var second_weapon = preload("res://scene/weapon/gun_2.tscn")
var player_data : PlayerData
var weapon_reloadding : bool = false
var first_weapon_bullet_count : int
var second_weapon_bullet_count : int

# 玩家信号
signal on_player_hp_changed(_current,_max) # 玩家血量改变信号
signal on_player_death() # 玩家死亡信号

# 武器信号
signal on_bullet_count_changed(_current,_max) # 子弹数量改变信号
signal on_weapon_reload() # 武器换弹匣信号
signal on_weapon_reload_completed() # 武器换弹匣完毕信号
signal on_weapon_changed(weapon: BaseWeapon) # 切换武器信号


func _ready() -> void:
	player_data = PlayerData.new() # 直接创建一个，后续做存档会修改
	on_weapon_reload.connect(_on_weapon_reload)
	on_weapon_reload_completed.connect(_on_weapon_reload_completed)
	on_bullet_count_changed.connect(_on_bullet_count_changed)


# 切换武器
func change_weapon(weapon: BaseWeapon) -> void:
	var current_weapon = Game.player.weapon_node.get_child(0)
	if current_weapon:
		current_weapon.queue_free()

	weapon.player = Game.player
	Game.player.weapon_node.add_child(weapon)
	Game.player.audio_player_component.play_random()


# 判断玩家是否死亡
func is_death() -> bool:
	if player_data:
		return player_data.current_hp <= 0
	return false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if weapon_reloadding == true : 
			print("换弹中，无法切换武器")
			return
		if Game.current_weapon.weapon_index == 1:
			var second_weapon_instance = second_weapon.instantiate()
			change_weapon(second_weapon_instance)
		else:
			var first_weapon_instance = first_weapon.instantiate()
			change_weapon(first_weapon_instance)


func _on_weapon_reload() -> void:
	weapon_reloadding = true


func _on_weapon_reload_completed() -> void:
	weapon_reloadding = false


func _on_bullet_count_changed(_current_bullet_count: int , _bullet_max: int) -> void:
	if Game.current_weapon.weapon_index == 1:
		first_weapon_bullet_count = _current_bullet_count
	elif Game.current_weapon.weapon_index == 2:
		second_weapon_bullet_count = _current_bullet_count
