extends Node2D

@onready var pressed_sound: AudioStreamPlayer = $PressedSound
@onready var sound_button: TextureButton = $CanvasLayer/SoundButton


func _ready() -> void:
	MusicManager.sync_sound_button(sound_button)
	#_animate_intro()

func _on_sound_button_pressed() -> void:
	pressed_sound.play()
	MusicManager.toggle_music()
	MusicManager.sync_sound_button(sound_button)

	# Small flash/pulse on the cart icon as feedback, no size change
	var sound_tween := create_tween()
	sound_tween.tween_property(sound_button, "modulate", Color(1.3, 1.3, 1.3), 0.1)
	sound_tween.tween_property(sound_button, "modulate", Color(1, 1, 1), 0.2)


func _on_play_button_pressed() -> void:
	pressed_sound.play()
	get_tree().change_scene_to_file("res://scene/first_play_scene.tscn")
