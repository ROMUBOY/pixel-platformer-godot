extends CharacterBody2D
class_name Player

@export var moveDate : Resource

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


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
			$AnimatedSprite2D.flip_h = direction > 0
	else:
		apply_friction()
		if is_on_floor():
			$AnimatedSprite2D.play("idle")
		
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = moveDate.JUMP_VELOCITY
	else:
		if Input.is_action_just_released("ui_accept") and velocity.y < moveDate.jump_release_force:
			velocity.y = moveDate.jump_release_force
		if velocity.y > 0:
			velocity.y += moveDate.additional_fall_gravity
	
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
	velocity.x = move_toward(velocity.x, 0, moveDate.friction)

func apply_aceleration(amount):
	velocity.x = move_toward(velocity.x, moveDate.SPEED * amount, moveDate.acceleration)
