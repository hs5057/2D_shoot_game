extends CanvasLayer

@onready var attribute_item_choose: GridContainer = %AttributeItemChoose
@onready var attribute_item_template: Panel = %AttributeItemTemplate

@onready var attr_list: VBoxContainer = %AttrList
@onready var attr_template: HBoxContainer = %AttrTemplate

@onready var refresh_button: Button = %RefreshButton
@onready var continue_button: Button = %ContinueButton

@onready var update_label: Label = %UpdateLabel
@onready var rich_text_label: RichTextLabel = $HBoxContainer/MarginContainer3/VBoxContainer/AttributeItemChoose/AttributeItemTemplate/RichTextLabel

var is_pause: bool = false

const ATTR_GROUP = {
	"attack" : {
		"name" : "攻击力",
		"type1" : {
			"name" : "基础伤害叠加",
			"img" : "basic_damage"
		},
		"type2" : {
			"name" : "基础伤害倍率",
			"img" : "basic_damage_multiple"
		},
	},
	"hp" : {
		"name" : "血量",
		"type1" : {
			"name" : "最大血量",
			"img" : "max_hp",
		},
		"type2" : {
			"name" : "每秒恢复血量",
			"img" : "health_recovery_rate",
		},
	},
	"speed" : {
		"name" : "速度",
		"type1" : {
			"name" : "移动速度",
			"img" : "run_speed",
		},
	},
	"critical_rate" : {
		"name" : "暴击率",
		"type1" : {
			"name" : "暴击率",
			"img" : "critical_rate",
		},
	},
	"critical_damage_multiple" : {
		"name" : "暴击伤害",
		"type1" : {
			"name" : "暴击伤害倍率",
			"img" : "critical_damage_multiple",
		},
	},
	"pick_up_radius" : {
		"name" : "拾取范围",
		"type1" : {
			"name" : "拾取范围",
			"img" : "pick_up_radius",
		},
	},
}

const ATTR_DATA = {
	"basic_damage" : {
		"group" : ATTR_GROUP.attack,
		"type" : "type1",
		"range" : "1-3",
	},
	"basic_damage_multiple" : {
		"group" : ATTR_GROUP.attack,
		"type" : "type2",
		"range" : "0.1-0.3",
	},
	"run_speed" : {
		"group" : ATTR_GROUP.speed,
		"type" : "type1",
		"range" : "2-5",
	},
	"max_hp" : {
		"group" : ATTR_GROUP.hp,
		"type" : "type1",
		"range" : "3-7",
	},
	"health_recovery_rate" : {
		"group" : ATTR_GROUP.hp,
		"type" : "type2",
		"range" : "1-5",
	},
	"pick_up_radius" : {
		"group" : ATTR_GROUP.pick_up_radius,
		"type" : "type1",
		"range" : "1-5",
	},
	"critical_rate" : {
		"group" : ATTR_GROUP.critical_rate,
		"type" : "type1",
		"range" : "0.01-0.03",
	},
	"critical_damage_multiple" : {
		"group" : ATTR_GROUP.critical_damage_multiple,
		"type" : "type1",
		"range" : "0.01-0.05",
	}
}

# 刷新次数
var refresh_count: int = 0
var base_refresh_coin: int = 2


func _ready() -> void:
	attribute_item_template.hide()
	attr_template.hide()
	refresh_button.pressed.connect(_on_refresh_button_pressed)
	refresh_button.text = "刷新-" + str(base_refresh_coin)
	continue_button.pressed.connect(_on_continue_button_pressed)

	pass


func init() -> void:
	set_pause()
	# 属性加成选择
	gen_attr_choose()
	
	# 加载玩家属性值
	load_player_attr()

	pass


func set_pause() -> void:
	if is_pause:
		self.hide()
		get_tree().paused = false
		is_pause = false
	else:
		self.show()
		get_tree().paused = true
		is_pause = true


# 生成属性加成选择
func gen_attr_choose() -> void:
	# 遍历并清空attribute_item_choose下的所有显示中的子节点
	for item in attribute_item_choose.get_children():
		if item.is_visible():
			attribute_item_choose.remove_child(item)
			item.queue_free()
	
	# 生成4个属性加成选择
	for i in range(4):
		var attribute_item = attribute_item_template.duplicate()
		attribute_item.show()
		
		var keys = ATTR_DATA.keys()
		var number = randi_range(0 , keys.size()-1)
		
		# 设置图片和名字
		attribute_item.get_node("MarginContainer/HBoxContainer/Panel/TextureRect").texture = \
			load("res://texture/attribute_item/" + \
			ATTR_DATA[keys[number]].group[ATTR_DATA[keys[number]].type].img + ".png")
		attribute_item.get_node("MarginContainer/HBoxContainer/VBoxContainer/Label").text = \
			ATTR_DATA[keys[number]].group.name

		# 设置随机数值和类型名文本
		# 分割字符串
		var _range = ATTR_DATA[keys[number]].range.split("-")
		# 判断是整数还是浮点数，并生成对应的随机值
		var _temp_number = float(_range[0])
		var _final_number
		var _final_number_to_str
		if _temp_number == int(_temp_number):
			_final_number = randi_range( int(_range[0]) , int(_range[1]) )
			_final_number_to_str = str( _final_number )
		else:
			_final_number = round(randf_range( float(_range[0]) , float(_range[1]) ) * 100) / 100
			#print("randf_range:",_final_number)
			_final_number_to_str = str( round(_final_number * 100) ) + "%"
		
		# 设置随机数值+类型名字
		attribute_item.get_node("RichTextLabel").text = "[color=green]+" + \
			_final_number_to_str + "[/color]" + \
			ATTR_DATA[keys[number]].group[ATTR_DATA[keys[number]].type].name
		
		# 链接选择按钮的信号
		attribute_item.get_node("Button").pressed.connect(choose_attr.bind({
			"name" : ATTR_DATA[keys[number]].group[ATTR_DATA[keys[number]].type].name,
			"key" : keys[number],
			"attr" : ATTR_DATA[keys[number]],
			"value" : _final_number,
		}))
		
		
		# 添加到子节点
		attribute_item_choose.add_child(attribute_item)


# 选择属性
func choose_attr(attr_info: Dictionary) -> void:
	continue_button.disabled = false
	PlayerManager.player_data[attr_info.key] += attr_info.value
	print("选择了:",attr_info.name)
	print("属性点:",PlayerManager.player_data[attr_info.key])
	#print(attr_info.name)
	#print(PlayerManager.player_data[attr_info.key])
	call_deferred("set_button_to_disabled")
	call_deferred("load_player_attr")
	pass


func set_button_to_disabled() -> void:
	for item in attribute_item_choose.get_children():
		item.get_node("Button").disabled = true
	%RefreshButton.disabled = true


# 加载玩家属性值
func load_player_attr() -> void:
	# 遍历并清空attr_list下的所有子节点
	for item in attr_list.get_children():
		if item.is_visible():
			attr_list.remove_child(item)
			item.queue_free()
	
	var property_list = PlayerManager.player_data.get_script().get_script_property_list()
	for prop in property_list:
		if prop.name.rfind(".gd") == -1:
			if prop.name == "is_critical":
				continue
			var attr_item = attr_template.duplicate()
			attr_item.show()
			attr_item.get_node("name").text = tr(prop.name)
			attr_item.get_node("value").text = str(PlayerManager.player_data[prop.name])
			attr_list.add_child(attr_item)
			
			
	#print(property_list)


func _on_continue_button_pressed() -> void:
	set_pause()
	call_deferred("queue_free")


func _on_refresh_button_pressed() -> void:
	var _current_price = (refresh_count + 1) * 2
	PlayerManager.player_data.gold -= _current_price
	refresh_count += 1
	var _next_price = (refresh_count + 1) * 2
	refresh_button.text = "刷新-" + str((refresh_count + 1) * 2)
	gen_attr_choose()
	if PlayerManager.player_data.gold > _next_price:
		refresh_button.disabled = false
	else:
		refresh_button.disabled = true
