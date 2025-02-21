extends Node2D

@onready var label: Label = $Label


func _ready() -> void:
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	# 上升动画
	tween.tween_property(label , "scale", label.scale * 1.3 , 0.2)
	tween.parallel().tween_property(label , "position:y", label.position.y - 15, 0.2)
	
	# 下落动画
	tween.tween_property(label , "position:y", label.position.y - 10, 0.5)
	tween.parallel().tween_property(label , "scale", label.scale * 1 , 0.5)
	tween.parallel().tween_property(label , "modulate:a", 0, 0.5)
	
	await tween.finished
	queue_free()


func set_text(text: String) -> void:
	label.text = text
