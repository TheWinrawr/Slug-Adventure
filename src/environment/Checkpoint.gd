extends Area2D

signal activated(checkpoint)
var activated = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Checkpoint_body_entered(body):
	emit_signal("activated", self)
	$AnimationPlayer.play("activate")
	if !activated:
		$AudioStreamPlayer.play()
		activated = true
	pass # Replace with function body.
