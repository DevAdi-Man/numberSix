extends Node2D

@onready var pressed_sound: AudioStreamPlayer = $PressedSound
@onready var right_answer: AudioStreamPlayer = $RightAnswer
@onready var wrong_answer: AudioStreamPlayer = $WrongAnswer
@onready var sound_button: TextureButton = $CanvasLayer/SoundButton
@onready var leaf: TextureButton = $CanvasLayer/Leaf
@onready var leaf_2: TextureButton = $CanvasLayer/Leaf2
@onready var question_label: Label = $CanvasLayer/Banner/Question_label
@onready var question_2_label: Label = $CanvasLayer/Banner/Question2_label
@onready var question_1: AudioStreamPlayer = $Question1
@onready var question_2: AudioStreamPlayer = $Question2

var answer_locked := false

const DROP_IN_OFFSET := 60.0  # how far above the final position it starts, in pixels
const DROP_IN_DURATION := 0.5


func _ready() -> void:
	await _play_intro_sequence()


func _play_intro_sequence() -> void:
	await _drop_in_label(question_label)
	question_1.play()
	await question_1.finished

	await _drop_in_label(question_2_label)
	question_2.play()
	await question_2.finished


func _drop_in_label(label: Label) -> void:
	# Capture its editor-set position as the "landed" position
	var target_pos := label.position

	label.visible = true
	label.modulate.a = 0.0
	label.position = target_pos - Vector2(0, DROP_IN_OFFSET)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position", target_pos, DROP_IN_DURATION)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 1.0, DROP_IN_DURATION)

	await tween.finished


func _on_sound_button_pressed() -> void:
	pressed_sound.play()
	MusicManager.toggle_music()
	MusicManager.sync_sound_button(sound_button)
	var sound_tween := create_tween()
	sound_tween.tween_property(sound_button, "modulate", Color(1.3, 1.3, 1.3), 0.1)
	sound_tween.tween_property(sound_button, "modulate", Color(1, 1, 1), 0.2)


func _on_back_button_pressed() -> void:
	pressed_sound.play()
	await pressed_sound.finished
	get_tree().change_scene_to_file("res://scene/first_play_scene.tscn")


func _on_leaf_pressed() -> void:
	_handle_answer(leaf, false)

func _on_leaf_2_pressed() -> void:
	_handle_answer(leaf_2, true)


func _handle_answer(button: TextureButton, is_correct: bool) -> void:
	if answer_locked:
		return
	pressed_sound.play()
	_press_scale_effect(button)
	if is_correct:
		answer_locked = true
		right_answer.play()
		await right_answer.finished
		get_tree().change_scene_to_file("res://scene/third_play_scene.tscn")
	else:
		wrong_answer.play()


func _press_scale_effect(button: TextureButton) -> void:
	# Center the pivot so it scales from the middle, not the corner
	button.pivot_offset = button.size / 2
	var tween := create_tween()
	tween.tween_property(button, "scale", Vector2(0.9, 0.9), 0.08)
	tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.08)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.06)
