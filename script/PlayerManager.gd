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

# 经验升级信号
signal experience_updated(current_experience:float , target_experience:float , current_level:int)
# 经验收集信号
signal experience_collected(number:float) 
# 等级提升信号
signal level_up(current_experience:float , target_experience:float , current_level:int)

# 武器信号
signal on_bullet_count_changed(_current,_max) # 子弹数量改变信号
signal on_weapon_reload() # 武器换弹匣信号
signal on_weapon_reload_completed() # 武器换弹匣完毕信号
signal on_weapon_changed(weapon: BaseWeapon) # 切换武器信号

signal glod_changed(current_glod: int)


func _ready() -> void:
	# 初始化玩家数据
	player_data = PlayerData.new() # 直接创建一个，后续做存档会修改
	player_data.call_deferred("init_hp")
	
	# 信号连接
	on_weapon_reload.connect(_on_weapon_reload)
	on_weapon_reload_completed.connect(_on_weapon_reload_completed)
	on_bullet_count_changed.connect(_on_bullet_count_changed)
	experience_collected.connect(_on_experience_collected)
	
	# 启动血量恢复计时器
	start_health_recovery_timer()


# 启动血量恢复计时器
func start_health_recovery_timer() -> void:
	var recovery_timer = Timer.new()
	recovery_timer.wait_time = 1.0  # 每秒触发一次
	recovery_timer.autostart = true
	recovery_timer.timeout.connect(_on_health_recovery_timer_timeout)
	add_child(recovery_timer)


# 血量恢复逻辑
func _on_health_recovery_timer_timeout() -> void:
	if player_data.current_hp < player_data.max_hp and not is_death():  # 如果血量不满
		player_data.current_hp += player_data.health_recovery_rate  # 恢复血量
		player_data.current_hp = min(player_data.current_hp, player_data.max_hp)  # 确保不超过最大血量
		on_player_hp_changed.emit(player_data.current_hp, player_data.max_hp)  # 触发血量变化信号


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


# 切换武器按钮检测
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("change_weapon"):
		if weapon_reloadding == true : 
			print("换弹中，无法切换武器")
			return
		if Game.current_weapon.weapon_index == 1:
			var second_weapon_instance = second_weapon.instantiate()
			change_weapon(second_weapon_instance)
		else:
			var first_weapon_instance = first_weapon.instantiate()
			change_weapon(first_weapon_instance)


# 武器换弹中
func _on_weapon_reload() -> void:
	weapon_reloadding = true


# 武器换弹完成
func _on_weapon_reload_completed() -> void:
	weapon_reloadding = false


# 子弹数量发生改变
func _on_bullet_count_changed(_current_bullet_count: int , _bullet_max: int) -> void:
	if Game.current_weapon.weapon_index == 1:
		first_weapon_bullet_count = _current_bullet_count
	elif Game.current_weapon.weapon_index == 2:
		second_weapon_bullet_count = _current_bullet_count


# 拾取经验后
func _on_experience_collected(number: float) -> void:
	increment_experience(number)


# 增加经验
func increment_experience(number: float) -> void:
	player_data.gold += number
	player_data.current_experience = min(player_data.current_experience + number , player_data.max_experience)
	experience_updated.emit(player_data.current_experience , player_data.max_experience , player_data.current_level)
	
	# 如果当前经验值达到了当前目标经验值后，就进行升级处理
	if player_data.current_experience == player_data.max_experience:
		player_data.current_level += 1
		player_data.max_experience += player_data.TARGET_EXPERIENCE_GROWTH
		player_data.current_experience = 0
		experience_updated.emit(player_data.current_experience , player_data.max_experience , player_data.current_level)
		level_up.emit(player_data.current_experience , player_data.max_experience , player_data.current_level)


# 发射经验收集信号
func emit_experience_collected(number: float) -> void:
	experience_collected.emit(number)
