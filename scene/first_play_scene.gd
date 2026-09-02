extends Node2D

@onready var pressed_sound: AudioStreamPlayer = $PressedSound
@onready var sound_button: TextureButton = $CanvasLayer/SoundButton
@onready var right_answer: AudioStreamPlayer = $RightAnswer
@onready var wrong_answer: AudioStreamPlayer = $WrongAnswer
@onready var question_label: Label = $CanvasLayer/Banner/Question
@onready var question_2_label: Label = $CanvasLayer/Banner/Question2

@onready var button_1: Button = $CanvasLayer/HBoxContainer/AnswerBox1/Button1
@onready var button_2: Button = $CanvasLayer/HBoxContainer/AnswerBox2/Button2
@onready var button_3: Button = $CanvasLayer/HBoxContainer/AnswerBox3/Button3
@onready var button_4: Button = $CanvasLayer/HBoxContainer/AnswerBox4/Button4

@onready var answer_box_1: Panel = $CanvasLayer/HBoxContainer/AnswerBox1
@onready var answer_box_2: Panel = $CanvasLayer/HBoxContainer/AnswerBox2
@onready var answer_box_3: Panel = $CanvasLayer/HBoxContainer/AnswerBox3
@onready var answer_box_4: Panel = $CanvasLayer/HBoxContainer/AnswerBox4
@onready var question_1: AudioStreamPlayer = $Question1
@onready var question_2: AudioStreamPlayer = $Question2

var answer_locked := false  # prevents spamming after the correct answer is found

const COLOR_CORRECT := Color(0.4, 1.0, 0.4)   # greenish
const COLOR_WRONG := Color(1.0, 0.4, 0.4)     # reddish
const COLOR_NORMAL := Color(1, 1, 1)

const BORDER_WIDTH := 4
const DROP_IN_OFFSET := 60.0  # how far above the final position it starts, in pixels
const DROP_IN_DURATION := 0.5


func _ready() -> void:
	# Give each panel its own unique StyleBoxFlat so tweening one
	# doesn't affect the others (they'd share a resource otherwise).
	for box in [answer_box_1, answer_box_2, answer_box_3, answer_box_4]:
		_ensure_unique_stylebox(box)

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
	get_tree().change_scene_to_file("res://scene/main.tscn")


func _on_button_1_pressed() -> void:
	_handle_answer(button_1, answer_box_1, false)

func _on_button_2_pressed() -> void:
	_handle_answer(button_2, answer_box_2, false)

func _on_button_3_pressed() -> void:
	_handle_answer(button_3, answer_box_3, true)

func _on_button_4_pressed() -> void:
	_handle_answer(button_4, answer_box_4, false)


func _handle_answer(button: Button, box: Panel, is_correct: bool) -> void:
	if answer_locked:
		return

	pressed_sound.play()
	_press_scale_effect(box)

	if is_correct:
		answer_locked = true
		right_answer.play()
		_flash_panel_color(box, COLOR_CORRECT)
		_flash_panel_border(box, COLOR_CORRECT)
		_go_to_next_scene()
	else:
		wrong_answer.play()
		_flash_panel_color(box, COLOR_WRONG)
		_flash_panel_border(box, COLOR_WRONG)


func _press_scale_effect(box: Panel) -> void:
	box.pivot_offset = box.size / 2
	var tween := create_tween()
	tween.tween_property(box, "scale", Vector2(0.9, 0.9), 0.08)
	tween.tween_property(box, "scale", Vector2(1.05, 1.05), 0.08)
	tween.tween_property(box, "scale", Vector2(1.0, 1.0), 0.06)


func _flash_panel_color(box: Panel, color: Color) -> void:
	var tween := create_tween()
	tween.tween_property(box, "modulate", color, 0.1)
	if color == COLOR_WRONG:
		tween.tween_interval(0.3)
		tween.tween_property(box, "modulate", COLOR_NORMAL, 0.3)


func _flash_panel_border(box: Panel, color: Color) -> void:
	var style := box.get_theme_stylebox("panel") as StyleBoxFlat
	if style == null:
		return

	style.set_border_width_all(0)  # start from 0 so it "grows in"

	var tween := create_tween()
	tween.tween_method(
		func(w): style.set_border_width_all(w),
		0, BORDER_WIDTH, 0.1
	)
	style.border_color = color

	if color == COLOR_WRONG:
		tween.tween_interval(0.3)
		tween.tween_method(
			func(w): style.set_border_width_all(w),
			BORDER_WIDTH, 0, 0.3
		)


func _ensure_unique_stylebox(box: Panel) -> void:
	var style := box.get_theme_stylebox("panel")
	if style is StyleBoxFlat:
		box.add_theme_stylebox_override("panel", style.duplicate())
	else:
		# Panel has no StyleBoxFlat assigned yet — create a basic one
		var new_style := StyleBoxFlat.new()
		new_style.bg_color = Color(0.15, 0.15, 0.15)  # adjust to match your art
		new_style.set_border_width_all(0)
		new_style.border_color = COLOR_NORMAL
		box.add_theme_stylebox_override("panel", new_style)


func _go_to_next_scene() -> void:
	# Wait so the player actually sees/hears the correct-answer feedback
	# before the scene switches. Adjust the delay to taste.
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scene/second_play_scene.tscn")
