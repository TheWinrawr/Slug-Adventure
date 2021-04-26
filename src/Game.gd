extends Node2D

var player_path = preload("res://src/Player.tscn")
var checkpoint: Node2D = null
var camera = null
var start_pos = Vector2()

var level := 0
var started = false
var camera_moving = false

# Called when the node enters the scene tree for the first time.
func _ready():
	start_pos = $Player.position
	camera = get_tree().get_nodes_in_group("camera")[0]
	var checkpoints = get_tree().get_nodes_in_group("checkpoint")
	for cpoint in checkpoints:
		cpoint.connect("activated", self, "_on_checkpoint_activated")
	$Player.connect("died", self, "_on_player_died")
	
	get_tree().paused = true
	pass # Replace with function body.
	
func _input(event):
	if event.is_action_pressed("space") && !started:
		get_tree().paused = false
		started = true
		$StartScreen.visible = false
		$Music.play()
	if event.is_action_pressed("quit"):
		get_tree().quit()
		
func check_player_position(pos: Vector2):
	var h = get_viewport_rect().size.y
	if pos.y > (camera.position.y + h - h / 2):
		change_level(pos)
		move_camera()
	elif pos.y < (camera.position.y - h + h / 2):
		change_level(pos)
		move_camera()
		
func move_camera():
	if camera_moving:
		return
	camera_moving = true
	get_tree().paused = true
	var v_rect = get_viewport_rect()
	var h = v_rect.size.y
	var new_y = v_rect.size.y / 2 + level * v_rect.size.y
	$Tween.interpolate_property(camera, "position:y", camera.position.y, new_y, 1.5, Tween.TRANS_QUART, Tween.EASE_OUT)
	$Tween.start()
	
func change_level(pos: Vector2):
	var h = get_viewport_rect().size.y
	level = floor(pos.y / h)
	
func _on_checkpoint_activated(checkpoint: Area2D) -> void:
	self.checkpoint = checkpoint
	
func _on_player_died() -> void:
	yield(get_tree().create_timer(2), "timeout")
	var player = player_path.instance()
	if checkpoint:
		player.global_position = Vector2(checkpoint.global_position.x, checkpoint.global_position.y + 9)
		#player.global_position.y += 9
	else:
		player.position = start_pos
	change_level(player.position)
	player.connect("died", self, "_on_player_died")
	add_child(player)


func _on_Tween_tween_all_completed():
	get_tree().paused = false
	camera_moving = false
	pass # Replace with function body.
