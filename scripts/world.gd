extends Node2D

const PLAYER = preload("res://scenes/player.tscn")

@onready var camera_2d = $Camera2D
@onready var player = $Player
@onready var timer = $Timer

var player_spawn_location = Vector2.ZERO

func _ready():
	RenderingServer.set_default_clear_color(Color.SKY_BLUE);
	player.connect_camera(camera_2d)
	player_spawn_location = player.global_position
	Events.connect("player_died", Callable(self, "_on_player_died"))
	Events.connect("hit_checkpoint", Callable(self, "_on_hit_checkpoint"))

func _on_player_died():
	timer.start(1.0)
	await timer.timeout
	var player = PLAYER.instantiate()
	player.position = player_spawn_location
	add_child(player)
	player.connect_camera(camera_2d)

func _on_hit_checkpoint(checkpoint_position):
	player_spawn_location = checkpoint_position
