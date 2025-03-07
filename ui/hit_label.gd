extends Node2D

@onready var label: Label = $Label

func _ready() -> void:
	return
	#var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	## 上升动画
	#tween.tween_property(label , "scale", label.scale * 1.3 , 0.2)
	#tween.parallel().tween_property(label , "position:y", label.position.y - 15, 0.2)
	#
	## 下落动画
	#tween.tween_property(label , "position:y", label.position.y - 10, 0.5)
	#tween.parallel().tween_property(label , "scale", label.scale * 1 , 0.5)
	#tween.parallel().tween_property(label , "modulate:a", 0, 0.5)
#
	#await tween.finished
	#queue_free()


func set_text(text: String, is_critical: bool = false) -> void:
	# 暴击样式
	if is_critical:
		#print("暴击了")
		label.modulate = Color.RED
		label.text = text
		
		# 强化动画
		var crit_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		# 上升动画
		crit_tween.tween_property(label , "scale", label.scale * 2.5 , 0.2)
		crit_tween.parallel().tween_property(label , "position:y", label.position.y - 15, 0.2)
		
		# 下落动画
		crit_tween.tween_property(label , "position:y", label.position.y - 8, 0.5)
		crit_tween.parallel().tween_property(label , "scale", label.scale * 1.5 , 0.5)
		crit_tween.parallel().tween_property(label , "modulate:a", 0, 0.8)
		
		await crit_tween.finished
		queue_free()
	else:
		#print("没暴击")
		label.modulate = Color.WHITE
		label.scale = Vector2(1.0, 1.0)
		label.text = text
		var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
		# 上升动画
		tween.tween_property(label , "scale", label.scale * 1.3 , 0.2)
		tween.parallel().tween_property(label , "position:y", label.position.y - 15, 0.2)
		
		# 下落动画
		tween.parallel().tween_property(label , "scale", label.scale * 1 , 0.5)
		tween.parallel().tween_property(label , "modulate:a", 0, 0.5)
		tween.tween_property(label , "position:y", label.position.y - 10, 0.5)

		await tween.finished
		queue_free()
	
	
