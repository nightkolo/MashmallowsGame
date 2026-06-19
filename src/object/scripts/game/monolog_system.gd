@tool
extends Node
class_name MonologSystem

signal monolog_line_entered(is_index: int)
signal character_emotion_set(is_em: Millie.Expressions, is_eyes: Millie.Eyes)

signal monolog_started()
signal monolog_finished()

signal letter_showing_started()
signal letter_showing_finished()
signal letter_showed()

@export var auto_start: bool = true
@export var one_time: bool = true
@export var disable_player_control: bool = true
@export var reveal_name_at: int = -1

@export var flow: MonologFlow
@export_multiline var preview_line: String:
	set(value):
		preview_line = value
		if speech_bubble:
			if speech_bubble.label:
				speech_bubble.label.text = value

@export_group("Speech Bubble")
@export var speech_bubble_size: Vector2 = Vector2(300.0, 165.0) ## @experimental
@export_group("Parameters")
@export_multiline var BBcode_default: String = "[center][color=white][font_size=21.0][outline_size=5.0][outline_color=black][b]"
@export var letter_time: float = 0.04
@export var space_time: float = 0.08
@export var punctuation_time: float = 0.32
@export_category("Objects to Assign")
@export var speech_bubble: SpeechBubble
@export var character: NPCBoard
@export var speech_generic: AudioStream
@export var speech_a: AudioStream
@export var speech_e: AudioStream
@export var speech_i: AudioStream
@export var speech_o: AudioStream
@export var speech_u: AudioStream

@export var choice_1: Button
@export var choice_2: Button

var monolog_has_happened: bool = false
var is_monolog_active: bool = false:
	set(value):
		if is_monolog_active == value:
			return
		
		GameMgr.monolog_activated.emit(value)
		
		if disable_player_control:
			if GameMgr.current_player:
				GameMgr.current_player.no_move = value
		
		is_monolog_active = value
var can_advance_line: bool = false
var speed_it_up: bool = false
var displayed_text: String

var _letter_index: int = 0
var _current_line_index: int
var _monolog_spawn_timer: Timer
var _letter_show_timer: Timer = Timer.new()


func _ready() -> void:
	_letter_show_timer.one_shot = true
	add_child(_letter_show_timer)
	
	preview_line = ""
	
	## Monologue Tree
	if choice_1 && choice_2:
		choice_1.pressed.connect(_on_choice_1_pressed)
		choice_2.pressed.connect(_on_choice_2_pressed)
	##

	## SIGNALS
	if speech_bubble:
		monolog_started.connect(func():
			speech_bubble.show_bubble()
			)
			
	monolog_finished.connect(func():
		if speech_bubble:
			await speech_bubble.hide_bubble()
		
		monolog_has_happened = true
		)
	
	### MILLIE EXPRESSION UPDATE
	if character:
		character_emotion_set.connect(func(is_em: Millie.Expressions, is_eye: Millie.Eyes):
			var m: Millie = character.millie
			
			if is_em == Millie.Expressions.NEUTRAL:
				m.expression = is_em
				m.eyes = is_eye
				
			else:
				m.expression = is_em
			)
	##
	
	## Misc.
	if choice_1 && choice_2:
		choice_1.visible = false
		choice_2.visible = false
		choice_1.disabled = true
		choice_2.disabled = true

	letter_showing_finished.connect(func():
		can_advance_line = true

		if choice_1 && choice_2:
			if !is_deciding && is_branching_line && _current_b_line_index == 1:
				return

			show_monolog_options(is_deciding)
		)
	
	_letter_show_timer.timeout.connect(func():
		if !speed_it_up:
			_show_letter()
			letter_showed.emit()
		)
	##
	
	## BUBBLE POSITIONING AND RESIZING
	
	monolog_line_entered.connect(func(index: int):
		speed_it_up = false
		
		if speech_bubble && index != 0:
			speech_bubble.anim_next_monolog_arrow()
		
		if character:
			if reveal_name_at >= 0:
				character.anim_reveal_name(reveal_name_at - 1 >= _current_line_index)

		speech_bubble.bubble.size = speech_bubble_size
		# TODO: Auto-Resize Bubble
		print("Text size: " + str(displayed_text.length()))
		)
	
	await get_tree().create_timer(0.1).timeout
	
	speech_bubble.bubble.resized.connect(func():
		
		# TODO: Tween
		speech_bubble.label_container.size = speech_bubble.bubble.size
		
		var s := speech_bubble.bubble.size
		
		speech_bubble.bubble.pivot_offset_ratio = Vector2(1.0, 0.5)
		speech_bubble.bubble.position = Vector2(-s.x, -s.y * 0.5)
		speech_bubble.label_container.position = Vector2(-s.x, -s.y * 0.5)
		speech_bubble.spiral.position = Vector2(s.x * 0.5, s.y * 0.5)
		
		speech_bubble.monolog_arrow.position = Vector2(-25.0, s.y * 0.5)
		)
		
	speech_bubble.bubble.size = speech_bubble_size
	##
	
	#if auto_start:
		#goto_next_monolog()


func _unhandled_input(event: InputEvent) -> void:
	if !is_animation_line && (auto_start || is_monolog_active) && event.is_action_pressed("game_next_monolog"):
		goto_next_monolog()



func show_monolog_options(p_show: bool) -> void:
	choice_1.visible = p_show
	choice_2.visible = p_show
	choice_1.disabled = !p_show
	choice_2.disabled = !p_show
	if speech_bubble:
		speech_bubble.arrow.visible = !p_show
	if p_show:
		choice_1.grab_focus()


func speed_text() -> void:
	speech_bubble.label.visible_characters = displayed_text.length()
	speed_it_up = true
	letter_showing_finished.emit()


func goto_next_monolog() -> void:
	if !is_monolog_active:
		start()
		return
		
	if !can_advance_line:
		if _monolog_spawn_timer.time_left == 0.0: # Monolog has spawned
			speed_text()
		return
	
	if is_deciding:
		return
	
	Audio.monolog_next.play()

	if is_branching_line:

		if _current_b_line_index < temp_b_monolog_flow.size():
			move_to_next_branching_line()
		else:
			is_branching_line = false
			goto_next_monolog()
		
		_current_b_line_index += 1
	else:
		_current_line_index += 1
		
		if _current_line_index < flow.monolog_flow.size():
			move_to_next_line()
		else:
			_monolog_spawn_timer.queue_free()
			stop()

# TODO: Clean-up

## MONOLOG TREE
var temp_b_monolog_flow: Array[MillieMonolog] = []
var _current_b_line_index: int:
	set(value):
		_current_b_line_index = value
# var prev_line: int = -1
var is_branching_line: bool = false
var is_deciding: bool = false


func move_to_next_branching_line():
	var line: MillieMonolog = temp_b_monolog_flow[mini(_current_b_line_index, temp_b_monolog_flow.size() - 1)]
	
	if line is MillieMonologLine:
		show_text(line.monolog_line)
		
		character_emotion_set.emit(line.monolog_emotion, line.monolog_eyes)
		monolog_line_entered.emit(_current_line_index)
	elif line is MillieMonologAnimation:
		check_and_play_animation(line)


var _choice_flow_1: Array[MillieMonolog]
var _choice_flow_2: Array[MillieMonolog]
var is_animation_line: bool:
	set(value):
		character.millie.is_animation_line = value
		is_animation_line = value

func move_to_next_line():
	if flow == null:
		return
	
	var line: MillieMonolog = flow.monolog_flow[_current_line_index]

	is_branching_line = line is MonologTree
	
	
	if line is MillieMonologLine || is_branching_line:
		

		show_text(line.monolog_line)

		character_emotion_set.emit(line.monolog_emotion, line.monolog_eyes)
		monolog_line_entered.emit(_current_line_index)

		# if choice_1 && choice_2:
		# 	choice_1.visible = is_branching_line
		# 	choice_2.visible = is_branching_line
		is_deciding = is_branching_line

		if is_branching_line:
			_current_b_line_index = 0
			
			if choice_1 && choice_2:
				choice_1.text = (line as MonologTree).monolog_path_1
				choice_2.text = (line as MonologTree).monolog_path_2

			_choice_flow_1 = (line as MonologTree).monolog_flow_1
			_choice_flow_2 = (line as MonologTree).monolog_flow_2
	elif line is MillieMonologAnimation:
		check_and_play_animation(line)


func check_and_play_animation(line: MillieMonolog) -> void:
	is_animation_line = line is MillieMonologAnimation


	if is_animation_line:
		if character:
			character_emotion_set.emit((line as MillieMonologAnimation).animate_expression, Millie.Eyes.REGULAR)
			# character.millie.expression = ((line as MillieMonologAnimation).animate_expression)
	else:
		return
	
	await get_tree().create_timer(1.5).timeout

	is_animation_line = false

	# if is_branching_line:
	# 	# _current_b_line_index += 1
	# 	move_to_next_branching_line()
	# else:
		# _current_line_index += 1
	goto_next_monolog()



func _on_choice_1_pressed():
	speed_text()
	choice_2.visible = false
	_selected_choice(_choice_flow_1)


func _on_choice_2_pressed():
	speed_text()
	choice_1.visible = false
	_selected_choice(_choice_flow_2)
	

func _selected_choice(p_flow: Array[MillieMonolog]) -> void:
	choice_1.disabled = true
	choice_2.disabled = true
	is_deciding = false
	temp_b_monolog_flow = p_flow
	goto_next_monolog()
##

func start() -> void:
	if is_monolog_active:
		return

	if one_time && monolog_has_happened:
			return

	Audio.monolog_on.play()
	move_to_next_line()
		#is_monolog_active = true in show_text


func stop() -> void:
	if is_monolog_active:
		Audio.monolog_off.play()

		monolog_finished.emit()

		character_emotion_set.emit(Millie.Expressions.NEUTRAL, Millie.Eyes.REGULAR)
		
		speech_bubble.label.text = ""
		_current_line_index = 0
		is_monolog_active = false


func show_text(text_to_show: String) -> void:
	if _monolog_spawn_timer != null:
		_monolog_spawn_timer.queue_free()
		
	if speech_bubble == null:
		return
	
	speed_it_up = false
	
	_monolog_spawn_timer = Timer.new()
	_monolog_spawn_timer.wait_time = 0.25
	_monolog_spawn_timer.one_shot = true
	add_child(_monolog_spawn_timer)
	
	can_advance_line = false
	_letter_index = 0

	speech_bubble.label.text = BBcode_default + text_to_show
	displayed_text = speech_bubble.label.get_parsed_text()
	
	_show_letter()
	
	_monolog_spawn_timer.start()
	letter_showing_started.emit()
	
	if !is_monolog_active:
		monolog_started.emit()
		
	is_monolog_active = true


func _show_letter() -> void:
	speech_bubble.label.visible_characters = _letter_index + 1
	
	_letter_index += 1
	
	if _letter_index < displayed_text.length():
		var current_letter := displayed_text[_letter_index]
		
		if !speed_it_up:
		
			match current_letter:
				
				"!", ",", "?":
					_letter_show_timer.start(punctuation_time)
					
				" ":
					_letter_show_timer.start(space_time)
				
				".":
					_letter_show_timer.start(letter_time)
				
				_:
					play_speech(displayed_text[_letter_index])
					_letter_show_timer.start(letter_time)
					
	else:
		letter_showing_finished.emit()


func play_speech(letter: String = "") -> void:
	if speech_generic == null:
		return

	var aud :=  AudioStreamPlayer.new()
	match letter:
		"a":
			aud.stream = speech_a
		"e":
			aud.stream = speech_e
		"i":
			aud.stream = speech_i
		"o":
			aud.stream = speech_o
		"u":
			aud.stream = speech_u
		_:
			aud.stream = speech_generic

	add_child(aud)
	
	if letter in ["a", "e", "i", "o", "u"]:
		aud.pitch_scale = randf_range(0.9,1.1) + 0.3
		aud.volume_db = -25.0
	else:
		aud.pitch_scale = randf_range(0.9,1.1)
		aud.volume_db = -20.0
		
	aud.play()
	await aud.finished
	aud.queue_free()
