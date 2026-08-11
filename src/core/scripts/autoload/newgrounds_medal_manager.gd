## Newgrounds Medal and Stat Manager
extends CanvasLayer

@onready var label: Label = %Label
@onready var label_2: Label = %Label2
@onready var h_box_container: HBoxContainer = %HBoxContainer
@onready var particles: CPUParticles2D = %Particles
@onready var texture_rect: TextureRect = %TextureRect


func _ready() -> void:
	visible = false
	
	if !GameMgr.ON_NEWGROUNDS_MIRROR:
		return
	
	texture_rect.pivot_offset_ratio = Vector2.ONE * 0.5
	
	var t := create_tween().set_loops()
	t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.tween_property(texture_rect, "rotation", TAU, 2.0).from(0.0)
	
	# Medals are checkered when GameMgr.game_data_saved is emitted
	# GameMgr.game_data_saved is emitted by Stage (Level code) on GameMgr.game_just_ended.
	# Stage sets the runtime_data,
	# then this autoload checks for progression medals from runtime_data.
	GameMgr.game_data_saved.connect(func():
		check_board_progression_medals()
		check_player_stat_medals()
	)
	
	GameLogic.player_mashed.connect(update_mashes_made)
	GameLogic.player_squated.connect(update_squats_made)


	
## Unlocks the Newgrounds medals by their[br]
## [param medal_code]: The medal code (the game uses to store data) for the medal.[br]
## [param medal_id]: The medal ID (Newgrounds.io uses to unlock medals on newgrounds.com) for the medal.[br][br]
## Must be called with [code]await[/code].
func unlock_a_medal(medal_code: String, medal_id: int, pop_up: bool = false) -> void:
	if !GameMgr.ON_NEWGROUNDS_MIRROR:
		return
	
	if !GameData.medal_data.has(medal_code):
		print("Could not find " + str(medal_code) + " in GameData.medal_data.")
		return
	
	if pop_up && GameData.medal_data[medal_code] == false:
		anim_medal_unlocked(medal_id)
	
	var res: bool = await NG.medal_unlock(medal_id)
	
	if res:
		## Debug
		var medals: Array[MedalResource] = await NG.medal_get_list()
		
		for medal: MedalResource in medals:
			if medal.id == medal_id:
				print("Medal Name: " + str(medal.name) + ". ID: " + str(medal.id) + ". Unlocked: " + str(medal.unlocked))
				break
		
		if GameData.medal_data[medal_code] == false:
			GameData.medal_data[medal_code] = true
			
			print("Medal unlocked (code): ", medal_code)
			
			GameMgr.save_game_medals_data()
		
		
		
	else:
		print("Could not unlock medal :(")
	

func update_squats_made() -> void:
	if GameData.runtime_data.has("squats_made"):
		GameData.runtime_data["squats_made"] += 1
		
		
func update_mashes_made() -> void:
	var p: Player = GameMgr.current_player
	
	if p:
		if p.is_being_flown():
			await unlock_a_medal("midair", NewgroundsIds.MedalId.PopAndLock, true)
	
	if GameData.runtime_data.has("mashes_made"):
		GameData.runtime_data["mashes_made"] += 1


func check_player_stat_medals() -> void:
	if GameData.runtime_data.has("squats_made") && GameData.runtime_data.has("mashes_made"):
#
		if GameData.runtime_data["squats_made"] > 50:
			await unlock_a_medal("100squat", NewgroundsIds.MedalId.BigButt, true)
			
		if GameData.runtime_data["mashes_made"] > 200:
			await unlock_a_medal("200mash", NewgroundsIds.MedalId.ILikeToMash, true)


func check_board_progression_medals() -> void:
	if GameData.runtime_data.has("101") && GameData.runtime_data.has("102"):

		if GameData.runtime_data["101"]["completed"] == true:
			await unlock_a_medal("b1_comp", NewgroundsIds.MedalId.FirstBakeryComplete, true)
				
		if GameData.runtime_data["102"]["completed"] == true:
			await unlock_a_medal("b2_comp", NewgroundsIds.MedalId.SecondBakeryComplete, true)
		
		if GameData.runtime_data["101"]["completed"] == true && GameData.runtime_data["102"]["completed"] == true:
			await unlock_a_medal("game_comp", NewgroundsIds.MedalId.MarshmallowLadyApproves, true)



var _tween: Tween
var is_animating: bool = false
var current_medal_id: int

signal medal_anim_finished()

func anim_medal_unlocked(medal_id: int = 0) -> void:
	if !GameMgr.ON_NEWGROUNDS_MIRROR:
		return
		
	if is_animating:
		if current_medal_id != medal_id:
			await medal_anim_finished
		else:
			return
	
	current_medal_id = medal_id
	
	is_animating = true
	
	await get_tree().create_timer(0.5).timeout
	
	var dur := 1.0
	
	if _tween:
		_tween.kill()
	
	var m_res: MedalResource = NG.get_medal_resource(medal_id)
	
	var medal_name: String = '"%s"' % m_res.name
	label_2.text = medal_name
	
	Audio.medal_unlock.play()
	visible = true
	
	particles.emitting = true
	h_box_container.modulate = Color(Color.WHITE, 0.0)
	
	_tween = create_tween().set_parallel(true)
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	_tween.tween_property(h_box_container, "modulate", Color(Color.WHITE, 1.0), dur / 2.0)
	_tween.tween_property(h_box_container, "modulate", Color(Color.WHITE, 0.0), dur * 2.0).set_delay(dur * 2.0)
	
	await get_tree().create_timer(dur * 5.0).timeout
	
	visible = false
	is_animating = false
	medal_anim_finished.emit()
