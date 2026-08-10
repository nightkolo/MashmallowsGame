## Newgrounds Medal and Stat Manager
extends Node


func _ready() -> void:
	if !GameMgr.ON_NEWGROUNDS_MIRROR:
		return
	
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
func unlock_a_medal(medal_code: String, medal_id: int) -> void:
	if !GameMgr.ON_NEWGROUNDS_MIRROR:
		return
	
	if !GameData.medal_data.has(medal_code):
		print("Could not find " + str(medal_code) + " in GameData.medal_data.")
	
	await NG.medal_unlock(medal_id)
	
	## Debug
	var medals: Array[MedalResource] = await NG.medal_get_list()
	
	for medal: MedalResource in medals:
		if medal.id == medal_id:
			print("Medal Name: " + str(medal.name) + ". ID: " + str(medal.id) + ". Unlocked: " + str(medal.unlocked))
			break
	
	if !GameData.medal_data.has(medal_code):
		return
	
	if GameData.medal_data[medal_code] == false:
		GameData.medal_data[medal_code] = true
		
		print("Medal unlocked (code): ", medal_code)
		
		GameMgr.save_game_medals_data()
	

func update_squats_made() -> void:
	if GameData.runtime_data.has("squats_made"):
		GameData.runtime_data["squats_made"] += 1
		
		
func update_mashes_made() -> void:
	if GameData.runtime_data.has("mashes_made"):
		GameData.runtime_data["mashes_made"] += 1


func check_player_stat_medals() -> void:
	if GameData.runtime_data.has("squats_made") && GameData.runtime_data.has("mashes_made"):
#
		if GameData.runtime_data["squats_made"] > 50:
			await unlock_a_medal("100squat", NewgroundsIds.MedalId.BigButt)
			
		if GameData.runtime_data["mashes_made"] > 200:
			await unlock_a_medal("200mash", NewgroundsIds.MedalId.ILikeToMash)


func check_board_progression_medals() -> void:
	if GameData.runtime_data.has("101") && GameData.runtime_data.has("102"):

		if GameData.runtime_data["101"]["completed"] == true:
			await unlock_a_medal("b1_comp", NewgroundsIds.MedalId.FirstBakeryComplete)
				
		if GameData.runtime_data["102"]["completed"] == true:
			await unlock_a_medal("b2_comp", NewgroundsIds.MedalId.SecondBakeryComplete)
		
		if GameData.runtime_data["101"]["completed"] == true && GameData.runtime_data["102"]["completed"] == true:
			await unlock_a_medal("game_comp", NewgroundsIds.MedalId.MarshmallowLadyApproves)
