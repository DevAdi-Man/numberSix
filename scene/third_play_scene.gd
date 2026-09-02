extends Node2D

@onready var pressed_sound: AudioStreamPlayer = $PressedSound
@onready var right_answer: AudioStreamPlayer = $RightAnswer
@onready var wrong_answer: AudioStreamPlayer = $WrongAnswer
@onready var sound_button: TextureButton = $CanvasLayer/SoundButton
@onready var back_button: TextureButton = $CanvasLayer/BackButton
@onready var outside_lady_bird_4: TextureRect = $CanvasLayer/OutsideLadyBird4
@onready var outside_lady_bird_5: TextureRect = $CanvasLayer/OutsideLadyBird5
@onready var lady_bird_5: TextureRect = $CanvasLayer/Leaf/LadyBird5
@onready var lady_bird_6: TextureRect = $CanvasLayer/Leaf/LadyBird6
@onready var question_label: Label = $CanvasLayer/Banner/Question_label
@onready var question_2_label: Label = $CanvasLayer/Banner/Question2_label
@onready var question_1: AudioStreamPlayer = $Question1
@onready var question_2: AudioStreamPlayer = $Question2

const DROP_IN_OFFSET := 60.0
const DROP_IN_DURATION := 0.5

var birds_landed := 0
const TOTAL_BIRDS := 2


func _ready() -> void:
	outside_lady_bird_4.mouse_filter = Control.MOUSE_FILTER_STOP
	outside_lady_bird_5.mouse_filter = Control.MOUSE_FILTER_STOP
	outside_lady_bird_4.gui_input.connect(_on_outside_lady_bird_4_input)
	outside_lady_bird_5.gui_input.connect(_on_outside_lady_bird_5_input)
	await _play_intro_sequence()


func _play_intro_sequence() -> void:
	await _drop_in_label(question_label)
	question_1.play()
	await question_1.finished

	await _drop_in_label(question_2_label)
	question_2.play()
	await question_2.finished


func _drop_in_label(label: Label) -> void:
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


func _on_back_button_pressed() -> void:
	pressed_sound.play()
	await pressed_sound.finished
	get_tree().change_scene_to_file("res://scene/second_play_scene.tscn")


func _on_sound_button_pressed() -> void:
	pressed_sound.play()
	MusicManager.toggle_music()
	MusicManager.sync_sound_button(sound_button)
	var sound_tween := create_tween()
	sound_tween.tween_property(sound_button, "modulate", Color(1.3, 1.3, 1.3), 0.1)
	sound_tween.tween_property(sound_button, "modulate", Color(1, 1, 1), 0.2)


func _on_outside_lady_bird_4_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_move_ladybird_in(outside_lady_bird_4, lady_bird_5)


func _on_outside_lady_bird_5_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_move_ladybird_in(outside_lady_bird_5, lady_bird_6)


func _move_ladybird_in(outside_bird: TextureRect, inside_bird: TextureRect) -> void:
	if not outside_bird.visible:
		return

	pressed_sound.play()
	outside_bird.pivot_offset = outside_bird.size / 2

	var tween := create_tween()
	tween.tween_property(outside_bird, "scale", Vector2(1.3, 1.3), 0.15)
	tween.tween_callback(func():
		outside_bird.hide()
		inside_bird.show()
		right_answer.play()
	)
	await tween.finished
	await right_answer.finished

	birds_landed += 1
	if birds_landed >= TOTAL_BIRDS:
		get_tree().change_scene_to_file("res://scene/main.tscn")
