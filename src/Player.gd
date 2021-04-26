extends KinematicBody2D

signal died

export(NodePath) var arrow_texture

onready var left_ray: RayCast2D = $LeftRay
onready var right_ray: RayCast2D = $RightRay
onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var arrow_sprite: Node2D = get_parent().get_node("ArrowTexture")

var death_scene = preload("res://src/PlayerDeath.tscn")
var camera: ShakeCamera = null

var speed = 50
var walk_speed = 50
var fly_speed = 100
var dir := Vector2.RIGHT
var prev_dir := Vector2.RIGHT
var wall_normal := Vector2.UP
var ray_offset = 1

var is_flying = false

# Called when the node enters the scene tree for the first time.
func _ready():
	camera = get_tree().get_nodes_in_group("camera")[0]
	var shape: RectangleShape2D = $GroundedCollisionShape.shape
	left_ray.position.x = -shape.extents.x + ray_offset
	right_ray.position.x = shape.extents.x - ray_offset
	
	_enable_ground_hitbox(true)
	pass # Replace with function body.
	
func launch(launch_dir: Vector2, change_prev_dir: bool = true) -> void:
	_enable_ground_hitbox(false)
	if change_prev_dir:
		prev_dir = dir
	dir = launch_dir
	wall_normal = -dir
	is_flying = true
	speed = fly_speed
	anim_player.play("fly")
	_display_arrow()
	
func change_dir(new_dir: Vector2, change_prev_dir: bool = true) -> void:
	if new_dir == -dir && !is_flying:
		dir = new_dir
		return
	elif is_flying:
		launch(new_dir, change_prev_dir)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	_get_input()
	_handle_wall_collisions()
	_move()
	_flip_sprite()
	get_parent().check_player_position(position)

func _get_input() -> void:
	if Input.is_action_just_pressed("space") && !is_flying:
		launch(wall_normal)
		camera.shake(2, 0.3)
		$SFX/Jump.play()

func _handle_wall_collisions() -> void:
	if get_slide_count() >= 1:
		
		var collision = get_slide_collision(0)
		var collider = collision.collider
		dir = wall_normal
		wall_normal = collision.normal
		if is_flying:
			is_flying = false
			_enable_ground_hitbox(true)
			dir = _get_dir_on_landing()
			speed = walk_speed
			anim_player.play("walk")
			arrow_sprite.visible = false

	elif !left_ray.is_colliding() && !right_ray.is_colliding() && !is_flying:
		var offset: Vector2 = (-wall_normal * 2 + dir) * ray_offset
		position += offset
		var temp_wall_normal = wall_normal
		wall_normal = dir
		dir = -temp_wall_normal
		
func _move() -> void:
	var velocity = speed * dir
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
	rotation = Vector2.UP.angle_to(wall_normal)

func _flip_sprite() -> void:
	var check_dir = dir
	if is_flying:
		check_dir = -prev_dir
	if check_dir == Vector2.RIGHT:
		$Sprite.flip_h = (wall_normal == Vector2.DOWN)
	elif check_dir == Vector2.LEFT:
		$Sprite.flip_h = (wall_normal == Vector2.UP)
	elif check_dir == Vector2.UP:
		$Sprite.flip_h = (wall_normal == Vector2.RIGHT)
	elif check_dir == Vector2.DOWN:
		$Sprite.flip_h = (wall_normal == Vector2.LEFT)

func _enable_ground_hitbox(enable: bool):
	$GroundedCollisionShape.disabled = !enable
	$Hurtbox/GroundHurtbox.disabled = !enable
	$FlyingCollisionShape.disabled = enable
	$Hurtbox/FlyingHurtbox.disabled = enable
	
func _get_dir_on_landing() -> Vector2:
	if prev_dir == Vector2.RIGHT:
		if wall_normal == Vector2.UP || wall_normal == Vector2.DOWN:
			return Vector2.RIGHT
		elif wall_normal == Vector2.RIGHT:
			return Vector2.UP
		elif wall_normal == Vector2.LEFT:
			return Vector2.DOWN
	elif prev_dir == Vector2.LEFT:
		if wall_normal == Vector2.UP || wall_normal == Vector2.DOWN:
			return Vector2.LEFT
		elif wall_normal == Vector2.RIGHT:
			return Vector2.DOWN
		elif wall_normal == Vector2.LEFT:
			return Vector2.UP
	elif prev_dir == Vector2.UP:
		if wall_normal == Vector2.LEFT || wall_normal == Vector2.RIGHT:
			return Vector2.UP
		elif wall_normal == Vector2.UP:
			return Vector2.LEFT
		elif wall_normal == Vector2.DOWN:
			return Vector2.RIGHT
	elif prev_dir == Vector2.DOWN:
		if wall_normal == Vector2.LEFT || wall_normal == Vector2.RIGHT:
			return Vector2.DOWN
		elif wall_normal == Vector2.UP:
			return Vector2.RIGHT
		elif wall_normal == Vector2.DOWN:
			return Vector2.LEFT
	return prev_dir
	
func _display_arrow() -> void:
	arrow_sprite.visible = true
	var arrow_dir = _get_dir_on_landing()
	arrow_sprite.rotation = Vector2.RIGHT.angle_to(arrow_dir)
	var space_state = get_world_2d().direct_space_state
	var to = position + dir * 500
	var from = position + dir * 8
	var result = space_state.intersect_ray(position, to, [self])
	if result:
		arrow_sprite.position = result.position
		arrow_sprite.position -= dir * 5


func _on_Hurtbox_body_entered(body):
	camera.shake(5, 1)
	var death_instance = death_scene.instance()
	death_instance.global_position = global_position
	get_parent().add_child(death_instance)
	emit_signal("died")
	arrow_sprite.visible = false
	queue_free()
	pass # Replace with function body.
