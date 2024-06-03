extends CanvasLayer

@onready var animationPlayer = $AnimationPlayer

signal transition_completed

func play_exit_transition():
	animationPlayer.play("exit_level")

func play_enter_transition():
	animationPlayer.play("enter_level")

func _on_animation_player_animation_finished(anim_name):
	emit_signal("transition_completed")
