extends CharacterBody2D
class_name Player

@export var SPEED = 100.0
@export var JUMP_VELOCITY = -280.0
@export var jump_release_force = -150
@export var acceleration = 10
@export var friction = 10

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var additional_fall_gravity = 4

func _ready():
	$AnimatedSprite2D.frames = load("res://assets/frames/playerGreenSkin.tres")

func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		apply_gravity(gravity * delta)		
		$AnimatedSprite2D.play("jump")
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	
	if direction:
		apply_aceleration(direction)
		if is_on_floor():
			$AnimatedSprite2D.play("run")
			if direction > 0:
				$AnimatedSprite2D.flip_h = true
			else:
				$AnimatedSprite2D.flip_h = false
	else:
		apply_friction()
		if is_on_floor():
			$AnimatedSprite2D.play("idle")
		
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	else:
		if Input.is_action_just_released("ui_accept") and velocity.y < jump_release_force:
			velocity.y = jump_release_force
		if velocity.y > 0:
			velocity.y += additional_fall_gravity
	
	var was_in_air = not is_on_floor()
	move_and_slide()
	var just_landed = is_on_floor() and was_in_air
	if just_landed:
		$AnimatedSprite2D.animation = "run"
		$AnimatedSprite2D.frame = 1

func apply_gravity(gravity):
	velocity.y += gravity
	velocity.y = min(velocity.y, 300)

func apply_friction():
	velocity.x = move_toward(velocity.x, 0, friction)

func apply_aceleration(amount):
	velocity.x = move_toward(velocity.x, SPEED * amount, acceleration)
