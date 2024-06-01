extends Node

@onready var audio_players = $AudioPlayers

const HURT_SOUND = preload("res://sounds/hurt_sound.ogg")
const JUMP_SOUND = preload("res://sounds/jump_sound.ogg")

func play_sound(sound):
	for audio_stream_player in audio_players.get_children():
		if not audio_stream_player.playing:
			audio_stream_player.stream = sound
			audio_stream_player.play()
			break
	
