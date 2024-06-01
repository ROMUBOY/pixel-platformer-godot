@tool
extends Path2D

enum ANIMATION_TYPE {
	Loop,
	Bounce
}

@export var animation_type:ANIMATION_TYPE: set = set_animation_type
@export var speed : int = 1 : set = set_speed

@onready var animation_player = $AnimationPlayer

func set_animation_type(value):
	animation_type = value
	var ap = find_child("AnimationPlayer")
	if ap:
		play_updated_animation(ap)

func set_speed(value):
	speed = value
	var ap = find_child("AnimationPlayer")
	if ap: ap.speed_scale = speed

func _ready():
	play_updated_animation(animation_player)

func play_updated_animation(ap):
	match animation_player:
		ANIMATION_TYPE.Loop: ap.play("LoopAlongPath")
		ANIMATION_TYPE.Bounce: ap.play("BounceAlongPath")
