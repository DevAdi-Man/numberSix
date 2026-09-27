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
@onready var next_button: TextureButton = $CanvasLayer/NextButton

const DROP_IN_OFFSET := 60.0
const DROP_IN_DURATION := 0.5

var birds_landed := 0
const TOTAL_BIRDS := 2
var target_pos_4: Vector2
var target_pos_5: Vector2


func _ready() -> void:
	next_button.visible = false
	outside_lady_bird_4.mouse_filter = Control.MOUSE_FILTER_STOP
	outside_lady_bird_5.mouse_filter = Control.MOUSE_FILTER_STOP
	outside_lady_bird_4.gui_input.connect(_on_outside_lady_bird_4_input)
	outside_lady_bird_5.gui_input.connect(_on_outside_lady_bird_5_input)
	
	target_pos_4 = lady_bird_5.global_position
	target_pos_5 = lady_bird_6.global_position
	lady_bird_5.hide()
	lady_bird_6.hide()
	
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
		outside_lady_bird_4.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_move_ladybird_in(outside_lady_bird_4, target_pos_4)


func _on_outside_lady_bird_5_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		outside_lady_bird_5.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_move_ladybird_in(outside_lady_bird_5, target_pos_5)


func _move_ladybird_in(outside_bird: TextureRect, target_pos: Vector2) -> void:
	pressed_sound.play()

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(outside_bird, "global_position", target_pos, 0.8)
	
	await tween.finished
	right_answer.play()
	await right_answer.finished

	birds_landed += 1
	if birds_landed >= TOTAL_BIRDS:
		var pannel_scene = preload("res://scene/pannel.tscn")
		var pannel_inst = pannel_scene.instantiate()
		add_child(pannel_inst)


func _on_next_button_pressed() -> void:
	pass
