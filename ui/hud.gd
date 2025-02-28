extends Control

@onready var hp_bar: ProgressBar = %HpBar
@onready var bullet_label: Label = %Bullet
@onready var weapon_name_label: Label = %WeaponName
@onready var weapon_texture: TextureRect = %WeaponTexture
@onready var level_label: Label = %LevelLabel
@onready var cross: TextureRect = %CrossTextureRect


func _ready() -> void:
	PlayerManager.on_player_hp_changed.connect(on_player_hp_changed)
	
	PlayerManager.on_bullet_count_changed.connect(on_bullet_count_changed)
	PlayerManager.on_weapon_reload.connect(on_weapon_reload)
	
	PlayerManager.on_weapon_changed.connect(on_weapon_changed)
	
	LevelManager.on_level_changed.connect(on_level_changed)
	
	Game.on_game_start.connect(func ():
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
		)

func _process(_delta: float) -> void:
	cross.position = get_global_mouse_position() - cross.size / 2


func on_level_changed(_level_data: LevelData) -> void:
	level_label.text = '关卡 %s' % LevelManager.current_level


func on_player_hp_changed(_current,_max) -> void:
	hp_bar.max_value = _max
	hp_bar.value = _current


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
	
