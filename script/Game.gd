extends Node

var player : Player # 玩家节点

signal on_game_start() # 游戏开始信号


# 伤害计算
# origin -> 原始 ， target -> 目标
func damage(origin:Node2D , target:Node2D) -> void:
	if origin is Player: # 玩家对怪物造成伤害
		if target is BaseEnemy:
			target.enemy_data.current_hp -= PlayerManager.player_data.damage
	
	if origin is BaseEnemy: # 怪物对玩家造成伤害
		if target is Player:
			PlayerManager.player_data.current_hp -= origin.enemy_data.damage
