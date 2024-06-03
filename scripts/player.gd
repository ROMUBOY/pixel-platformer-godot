extends CharacterBody2D
class_name Player

enum { MOVE, CLIMB }

@export var moveDate : Resource

var state = MOVE
var buffered_jump = false
var coyote_jump = false
var on_door = false

@onready var double_jump = moveDate.double_jump_count

@onready var ladder_check = $LadderCheck
@onready var jump_buffer_timer = $JumpBufferTimer
@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var remote_transform_2d = $RemoteTransform2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	$AnimatedSprite2D.frames = load("res://assets/frames/playerGreenSkin.tres")

func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	var direction = Vector2.ZERO
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")
	
	match state:
		MOVE: move_state(direction.x, delta)
		CLIMB: climb_state(direction)

func connect_camera(camera):
	var camera_path = camera.get_path()
	remote_transform_2d.remote_path = camera_path

func move_state(direction, delta):
	if is_on_ladder() and Input.is_action_just_pressed("move_up"):
		state = CLIMB
	
	if not is_on_floor():
		apply_gravity(gravity * delta)
		$AnimatedSprite2D.play("jump")
	
	handle_horizontal_movement(direction, delta)
	
	handle_jump(delta)
	
	var was_in_air = not is_on_floor()
	var was_on_floor = is_on_floor()
	
	move_and_slide()
	
	var just_landed = is_on_floor() and was_in_air
	if just_landed:
		$AnimatedSprite2D.animation = "run"
		$AnimatedSprite2D.frame = 1
	
	var just_left_ground = not is_on_floor() and was_on_floor
	if just_left_ground and velocity.y >= 0:
		coyote_jump = true
		coyote_jump_timer.start()

func handle_horizontal_movement(direction, delta):
	if direction:
		apply_aceleration(direction, delta)
		if is_on_floor():
			$AnimatedSprite2D.play("run")
			$AnimatedSprite2D.flip_h = direction > 0
	else:
		apply_friction(delta)
		if is_on_floor():
			$AnimatedSprite2D.play("idle")

func handle_jump(delta):
	if is_on_floor():
		reset_double_jump()
	
	if can_jump():
		input_jump()
	else:
		input_jump_release()
		
		input_double_jump()
		
		buffer_jump()
		
		fast_fall(delta)

func input_jump_release():
	if Input.is_action_just_released("jump") and velocity.y < moveDate.jump_release_force:
			velocity.y = moveDate.jump_release_force

func input_double_jump():
	if Input.is_action_just_pressed("jump") and double_jump > 0:
			SoundPlayer.play_sound(SoundPlayer.JUMP_SOUND)
			velocity.y = moveDate.JUMP_VELOCITY
			double_jump -= 1

func buffer_jump():
	if Input.is_action_just_pressed("jump"):
			buffered_jump = true
			jump_buffer_timer.start()

func fast_fall(delta):
	if velocity.y > 0:
			velocity.y += moveDate.additional_fall_gravity * delta

func reset_double_jump():
	double_jump = moveDate.double_jump_count

func input_jump():
	if Input.is_action_just_pressed("jump") or buffered_jump:
			SoundPlayer.play_sound(SoundPlayer.JUMP_SOUND)
			velocity.y = moveDate.JUMP_VELOCITY
			buffered_jump = false
			coyote_jump = false

func can_jump():
	return is_on_floor() or coyote_jump

func climb_state(direction):
	if not is_on_ladder():
		state = MOVE
	
	if direction.length() != 0:
		$AnimatedSprite2D.play("run")
	else:
		$AnimatedSprite2D.play("idle")
	
	velocity = direction * moveDate.climb_speed
	move_and_slide()

func player_die():
	SoundPlayer.play_sound(SoundPlayer.HURT_SOUND)
	queue_free()
	Events.emit_signal("player_died")

func is_on_ladder():
	if not ladder_check.is_colliding(): 
		return false
	
	var collider = ladder_check.get_collider()
	
	if not collider is Ladder: 
		return false
		
	return true

func apply_gravity(gravity):
	velocity.y += gravity
	velocity.y = min(velocity.y, 300)

func apply_friction(delta):
	velocity.x = move_toward(velocity.x, 0, moveDate.friction * delta)

func apply_aceleration(amount, delta):
	velocity.x = move_toward(velocity.x, moveDate.SPEED * amount, moveDate.acceleration * delta)

func _on_jump_buffer_timer_timeout():
	buffered_jump = false

func _on_coyote_jump_timer_timeout():
	coyote_jump = false
