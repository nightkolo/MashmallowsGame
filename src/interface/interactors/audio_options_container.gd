extends HBoxContainer
class_name OptionsContainer

signal option_entered(option: String)

@onready var sfx_btn: Button = %SFX
@onready var music_btn: Button = %Music
@onready var a_btn: Button = %A
@onready var sfx_icon: Sprite2D = $SFX/Node2D/Sprite2D
@onready var music_icon: Sprite2D = $Music/Node2D/Sprite2D
@onready var a_icon: Sprite2D = $A/Node2D/Sprite2D


func _ready() -> void:
	music_btn.self_modulate = Color(Color.WHITE, 0.0)
	sfx_btn.self_modulate = Color(Color.WHITE, 0.0)
	
	GameMgr.menu_entered.connect(func(_m: GameMgr.MenuID):
		update_options()
		)
	sfx_btn.focus_entered.connect(sfx_text)
	music_btn.focus_entered.connect(music_text)
	a_btn.focus_entered.connect(a_text)
		
	sfx_btn.pressed.connect(func():
		var setting : bool = GameMgr.get_game_sfx_muted_setting()
		GameMgr.set_game_sfx_muted(!setting)
		
		update_options()
		sfx_text()
		)
	music_btn.pressed.connect(func():
		var setting : bool = GameMgr.get_game_music_muted_setting()
		GameMgr.set_game_music_muted(!setting)
		
		update_options()
		music_text()
		)
	a_btn.pressed.connect(func():
		var setting : bool = GameMgr.get_adult_filter_on_setting()
		GameMgr.set_adult_filter_on(!setting)
		
		update_options()
		a_text()
		)

func sfx_text():
	var s := "OFF" if GameMgr.get_game_sfx_muted_setting() else "ON"
	option_entered.emit("SFX: %s" % s)

func music_text():
	var s := "OFF" if GameMgr.get_game_music_muted_setting() else "ON"
	option_entered.emit("Music: %s" % s)

func a_text():
	var s := "OFF" if GameMgr.get_adult_filter_on_setting() else "ON" 
	option_entered.emit("Adult Themes: %s" % s)


func update_options() -> void:
	if GameMgr.get_game_sfx_muted_setting():
		sfx_icon.self_modulate = Color(Color.WHITE/2.0, 1.0)
	else:
		sfx_icon.self_modulate = Color(Color.WHITE, 1.0)
	
	if GameMgr.get_game_music_muted_setting():
		music_icon.self_modulate = Color(Color.WHITE/2.0, 1.0)
	else:
		music_icon.self_modulate = Color(Color.WHITE, 1.0)
		
	if GameMgr.get_adult_filter_on_setting():
		a_icon.self_modulate = Color(Color.WHITE/2.0, 1.0)
	else:
		a_icon.self_modulate = Color(Color.WHITE, 1.0)
