extends Node2D

enum {HOVER, FALL, LAND, RISE}

var state = HOVER

@onready var start_position = global_position
@onready var timer = $Timer
@onready var ray_cast_2d = $RayCast2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var gpu_particles_2d = $GPUParticles2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match state:
		HOVER: hover_state()
		FALL: fall_state(delta)
		LAND: land_state()
		RISE: rise_state(delta)

func hover_state():
	state = FALL

func fall_state(delta):
	animated_sprite_2d.play("falling")
	position.y += 100 * delta
	if ray_cast_2d.is_colliding():
		var collision_point = ray_cast_2d.get_collision_point()
		position.y = collision_point.y
		state = LAND
		timer.start(1.0)
		gpu_particles_2d.emitting = true

func land_state():
	await timer.timeout
	state = RISE

func rise_state(delta):
	animated_sprite_2d.play("idle")
	position.y = move_toward(position.y, start_position.y, 20 * delta)
	if position.y == start_position.y:
		state = HOVER
