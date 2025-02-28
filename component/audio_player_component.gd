extends AudioStreamPlayer
class_name AudioPlayerComponent

@export var streams: Array[AudioStream]

# 定义一个音调范围，让声音更加多元化
@export var randomize_pitch = true
@export var min_pitch = 0.9
@export var max_pitch = 1.1



#随机播放
func play_random():
	if streams == null || streams.size() == 0:
		return

	if randomize_pitch:
		pitch_scale = randf_range(min_pitch, max_pitch)
	else:
		pitch_scale = 1

	# 随机选定一个播放音效，pick_random()从目标数组中返回一个随机值
	stream = streams.pick_random()
	# 播放声音
	play()
	
