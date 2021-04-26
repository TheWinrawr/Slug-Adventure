extends Area2D


var dir = Vector2.RIGHT

# Called when the node enters the scene tree for the first time.
func _ready():
	dir = dir.rotated(rotation).round()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Arrow_body_entered(body):
	if body.is_flying:
		body.position = position
	body.call_deferred("change_dir", dir, false)
	$HitSFX.play()
	pass # Replace with function body.
