extends Control

@onready var bullet_label: Label = %Bullet
@onready var weapon_name_label: Label = %WeaponName
@onready var weapon_texture: TextureRect = %WeaponTexture
@onready var level_label: Label = %LevelLabel
#@onready var cross: CanvasLayer = %CrossTextureRect
@onready var hp_bar: ProgressBar = %HpBar
@onready var hp_info: Label = %HpInfo
@onready var exp_bar: ProgressBar = %EXPBar
@onready var lv_info: Label = %LvInfo
@onready var coin_count: Label = %CoinCount


func _ready() -> void:
	exp_bar.value = 0
	lv_info.text = "lv.1"
	coin_count.text = str(PlayerManager.player_data.gold)
	
	PlayerManager.glod_changed.connect(_on_glod_changed)
	
	PlayerManager.experience_updated.connect(_on_experience_updated)
	PlayerManager.experience_collected.connect(_on_experience_collected)
	
	PlayerManager.on_player_hp_changed.connect(on_player_hp_changed)
	
	PlayerManager.on_bullet_count_changed.connect(on_bullet_count_changed)
	PlayerManager.on_weapon_reload.connect(on_weapon_reload)
	
	PlayerManager.on_weapon_changed.connect(on_weapon_changed)
	
	LevelManager.on_level_changed.connect(on_level_changed)
	
	Game.on_game_start.connect(func ():
		#Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
		pass
		)


func _process(_delta: float) -> void:
	#cross.texture.position = get_global_mouse_position() - cross.texture.size / 2
	pass


func on_level_changed(_level_data: LevelData) -> void:
	level_label.text = '关卡 %s' % LevelManager.current_level


func on_player_hp_changed(_current,_max) -> void:
	hp_bar.max_value = _max
	hp_bar.value = _current
	hp_info.text = "%s / %s" % [round(_current),_max]


func on_bullet_count_changed(_current,_max) -> void:
	bullet_label.text = "%s / %s" % [_current,_max]
	bullet_label["theme_override_colors/font_color"] = Color(1,1,1,1)


func on_weapon_reload() -> void:
	Game.show_label(Game.player,'正在换弹中...')
	bullet_label.text = "换弹中……"
	bullet_label["theme_override_colors/font_color"] = Color(1,1,0,1)


func on_weapon_changed(weapon: BaseWeapon) -> void:
	weapon_name_label.text = weapon.weapon_name
	weapon_texture.texture = weapon.sprite.texture
	


func _on_experience_updated(current_experience:float , target_experience:float , current_level:int) -> void:
	var percent = current_experience / target_experience
	exp_bar.value = percent
	lv_info.text = "lv. %s" % current_level


func _on_experience_collected(number:float) -> void:
	coin_count.text = str(PlayerManager.player_data.gold)


func _on_glod_changed(current_glod: int) -> void:
	coin_count.text = str(current_glod)
