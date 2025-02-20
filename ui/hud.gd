extends Control

@onready var hp_bar: ProgressBar = %HpBar
@onready var bullet_label: Label = %Bullet
@onready var weapon_name_label: Label = %WeaponName
@onready var weapon_texture: TextureRect = %WeaponTexture


func _ready() -> void:
	PlayerManager.on_player_hp_changed.connect(on_player_hp_changed)
	
	PlayerManager.on_bullet_count_changed.connect(on_bullet_count_changed)
	PlayerManager.on_weapon_reload.connect(on_weapon_reload)
	
	PlayerManager.on_weapon_changed.connect(on_weapon_changed)


func on_player_hp_changed(_current,_max) -> void:
	hp_bar.max_value = _max
	hp_bar.value = _current


func on_bullet_count_changed(_current,_max) -> void:
	bullet_label.text = "%s / %s" % [_current,_max]


func on_weapon_reload() -> void:
	bullet_label.text = "换弹中……"


func on_weapon_changed(weapon: BaseWeapon) -> void:
	weapon_name_label.text = weapon.weapon_name
	weapon_texture.texture = weapon.sprite.texture
	
