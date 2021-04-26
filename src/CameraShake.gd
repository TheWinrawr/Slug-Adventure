extends Camera2D

class_name ShakeCamera

var shake_duration = 1.0
var shake_time_left = 0.0
var magnitude = 8.0
var taper_off = true

var is_shaking = false

func shake(magnitude: float = 8.0, shake_duration: float = 1.0, taper_off: bool = true):
	if is_shaking && magnitude < self.magnitude:
		return
		
	self.magnitude = magnitude
	self.shake_duration = shake_duration
	self.taper_off = taper_off
	
	shake_time_left = shake_duration
	is_shaking = true
	
func _process(delta):
	if shake_time_left > 0:
		var m = magnitude * shake_time_left / shake_duration
		if !taper_off:
			m = magnitude
		offset.x = rand_range(-m, m)
		offset.y = rand_range(-m, m)
		
		shake_time_left -= delta
	else:
		offset = Vector2()
		is_shaking = false
