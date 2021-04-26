extends Area2D

var dir := Vector2.UP
var player: Node2D = null

var hitbox_active = true
var camera = null


# Called when the node enters the scene tree for the first time.
func _ready():
	dir = dir.rotated(rotation).round()
	camera = get_tree().get_nodes_in_group("camera")[0]
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Cannon_body_entered(body):
	if !hitbox_active:
		return
	hitbox_active = false
	player = body
	player.position.x = -500
	player.set_physics_process(false)
	$Cooldown.start()
	$AnimationPlayer.play("load")
	pass # Replace with function body.


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "load":
		player.set_physics_process(true)
		player.global_position = global_position + dir * 8
		player.launch(dir)
		$AnimationPlayer.play("fire")
		$ShootSFX.play()
		camera.shake(4, 0.7)
		
	pass # Replace with function body.


func _on_Cooldown_timeout():
	hitbox_active = true
	pass # Replace with function body.
