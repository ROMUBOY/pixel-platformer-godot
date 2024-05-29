extends CharacterBody2D
class_name Player

enum { MOVE, CLIMB }

@export var moveDate : Resource

var state = MOVE

@onready var ladder_check = $LadderCheck

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
	
	
	

func move_state(direction, delta):
	if is_on_ladder() and Input.is_action_just_pressed("move_up"):
		state = CLIMB
	# Add the gravity.
	if not is_on_floor():
		apply_gravity(gravity * delta)
		$AnimatedSprite2D.play("jump")
	
	if direction:
		apply_aceleration(direction)
		if is_on_floor():
			$AnimatedSprite2D.play("run")
			$AnimatedSprite2D.flip_h = direction > 0
	else:
		apply_friction()
		if is_on_floor():
			$AnimatedSprite2D.play("idle")
		
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = moveDate.JUMP_VELOCITY
	else:
		if Input.is_action_just_released("jump") and velocity.y < moveDate.jump_release_force:
			velocity.y = moveDate.jump_release_force
		if velocity.y > 0:
			velocity.y += moveDate.additional_fall_gravity
	
	var was_in_air = not is_on_floor()
	move_and_slide()
	var just_landed = is_on_floor() and was_in_air
	if just_landed:
		$AnimatedSprite2D.animation = "run"
		$AnimatedSprite2D.frame = 1

func climb_state(direction):
	if not is_on_ladder():
		state = MOVE
	
	if direction.length() != 0:
		$AnimatedSprite2D.play("run")
	else:
		$AnimatedSprite2D.play("idle")
	
	velocity = direction * 50
	move_and_slide()

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

func apply_friction():
	velocity.x = move_toward(velocity.x, 0, moveDate.friction)

func apply_aceleration(amount):
	velocity.x = move_toward(velocity.x, moveDate.SPEED * amount, moveDate.acceleration)
