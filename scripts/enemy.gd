extends CharacterBody2D

@export var speed : int = 25
var direction = Vector2.RIGHT

@onready var ledge_check_left = $LedgeCheckLeft
@onready var ledge_check_right = $LedgeCheckRight
@onready var sprite = $AnimatedSprite2D

func _physics_process(delta):	
	var found_ledge = not ledge_check_left.is_colliding() or not ledge_check_right.is_colliding()
	
		
	if is_on_wall() or found_ledge:
		direction *= -1
		sprite.flip_h = direction.x > 0
	
	velocity = direction * speed
	
	set_up_direction(Vector2.UP)
	set_floor_stop_on_slope_enabled(false)
	set_max_slides(4)
	set_floor_max_angle(deg_to_rad(80))
	move_and_slide()
