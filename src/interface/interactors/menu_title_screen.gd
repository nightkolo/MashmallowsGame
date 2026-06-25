class_name TitleScreen
extends MainMenu

signal start_btn_pressed()
signal select_board_btn_pressed()
signal credits_btn_pressed()

@onready var start_btn: Button = %StartButton
@onready var select_stage_btn: Button = %SelectStageButton
@onready var credits_btn: Button = %CreditsButton

@onready var author_text: RichTextLabel = %Authors

var version: String = ProjectSettings.get_setting("application/config/version")
var version_text: String = "[color=#FFFFFF5A]v%s
[color=#FFFFFFFF][font_size=20.0]© 2026 Night Kolo"


func _ready() -> void:
	start_btn.grab_focus()
	
	author_text.text = version_text % version

	
	is_showing.connect(func():
		start_btn.grab_focus()
		#
		GameMgr.menu_entered.emit(GameMgr.MenuID.TITLE)
		
		if GameData.runtime_data.has("last_level"):
			var lvl_num: int = GameData.runtime_data["last_level"]
			
			if lvl_num == 0:
				start_btn.text = "Start"
			else:
				start_btn.text = "Continue %s-%s" % [Util.get_bakery_number(lvl_num), int(lvl_num)]
		)
	
	start_btn.pressed.connect(continue_game)
	select_stage_btn.pressed.connect(goto_select_board)
	credits_btn.pressed.connect(goto_credits)
	
	print_debug(GameData.runtime_data)
	if GameData.runtime_data.has("last_level"):
		start_btn.text = "Continue 1-%s" % GameData.runtime_data["last_level"]
		#GameData.runtime_data
		
		#start_btn.text = "Start"


func goto_select_board() -> void:
	select_board_btn_pressed.emit()


func goto_credits() -> void:
	credits_btn_pressed.emit()


func continue_game() -> void:
	GameMgr.self_destruct()
	GameLogic.self_destruct()
	if !GameData.runtime_data.has("last_level"): 
		return
		
	var lvl: String = Util.LEVEL_FILE_BEGIN + str(int(GameData.runtime_data["last_level"])) + Util.LEVEL_FILE_END 
	
	print("Going to %s" % lvl)
	
	if FileAccess.file_exists(lvl):
		_disable_buttons(btns)
		
		await get_tree().create_timer(0.25).timeout
		
		Trans.slide_to_scene(lvl)
	
	#_disable_buttons(btns)
		
	#await get_tree().create_timer(0.25).timeout
	
	#Trans.slide_to_scene(Util.LEVEL_FILE_BEGIN + "0" + Util.LEVEL_FILE_END)


func _disable_buttons(p_btns: Array[Node], disable: bool = true) -> void:
	for btn: Button in p_btns:
		btn.disabled = disable
