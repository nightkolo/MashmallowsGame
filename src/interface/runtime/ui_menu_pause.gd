extends Control
class_name PauseScreen

@onready var bus_SFX: int = AudioServer.get_bus_index("SFX")
@onready var bus_Music: int = AudioServer.get_bus_index("Music")
@onready var bg: ColorRect = $BG

@onready var resume_btn: Button = %ResumeButton
@onready var reset_btn: Button = %ResetButton
@onready var op_btn: Button = %OptionsButton
@onready var quit_btn: Button = %ReturnButton

@onready var pause_info: RichTextLabel = %PauseInfo

@onready var btns: Array[Node] = get_tree().get_nodes_in_group("UIButton")

var _gameplay_ui: GameplayUI

const BBCODE_TXT = "[outline_size=8][outline_color=#3f3f3f][color=#ffffff][center][font_size=24]"
const PAUSE_INFO_BEGIN = "≈Order "
const PAUSE_INFO_END = " Paused≈"

var shader: ShaderMaterial = preload("res://core/resources/shader/pause_menu_blur.tres")

func _ready() -> void:
	process_mode = ProcessMode.PROCESS_MODE_WHEN_PAUSED
	
	bg.material = null
	bg.visible = false
	
	update_text()
	
	if get_parent() is GameplayUI:
		_gameplay_ui = get_parent() as GameplayUI
		
	else:
		push_warning(str(self) + " must be run in GameplayUI,")
		resume_btn.grab_focus()
		get_tree().paused = true
		visible = true
	
	visibility_changed.connect(func():
		#anim_bg_blur(visible)
		
		if visible:
			GameMgr.menu_entered.emit(GameMgr.MenuID.PAUSE)
			resume_btn.grab_focus()
			update_options()
			update_text()
		else:
			
			GameMgr.menu_entered.emit(GameMgr.MenuID.RUNTIME)
		)
		
	if _gameplay_ui:
		resume_btn.pressed.connect(func():
			_gameplay_ui.pause_or_unpause()
			)
			
		reset_btn.pressed.connect(func():
			_gameplay_ui.reset_stage()
			)

		op_btn.pressed.connect(func():
			# TODO: Skip til release
			_gameplay_ui.pause_or_unpause(false)
			GameMgr.goto_next_level(1)
		)
			
		quit_btn.pressed.connect(func():
			_gameplay_ui.allow_input = false
			Util.disable_buttons(btns)
			GameMgr.menu_entered.emit(GameMgr.MenuID.MENUS)
			
			_gameplay_ui.quit()
			)
	

func update_text() -> void:
	pause_info.text = BBCODE_TXT + PAUSE_INFO_BEGIN + "1-" + str(GameMgr.level_id) + PAUSE_INFO_END


var _t_blur: Tween

func anim_bg_blur(opne: bool): ## @experimental: Doesn't work on web export
	if _t_blur:
		_t_blur.kill()
		
	_t_blur = create_tween().set_parallel()
	if opne:
		(bg.material as ShaderMaterial).set_shader_parameter("blur_amount", 0.0)
		
		_t_blur.tween_property(bg.material as ShaderMaterial, "shader_parameter/blur_amount" ,3.0 ,0.1)
	else:
		_t_blur.tween_property(bg.material as ShaderMaterial, "shader_parameter/blur_amount" ,0.0 ,0.2)


func update_options() -> void:
	pass
	#update_text()
		#
	#if GameMgr.get_reduce_motion_setting():
		#reduce_motion_btn.text = "Reduce Motion: ON"
	#else:
		#reduce_motion_btn.text = "Reduce Motion: OFF"
		#
	#if GameMgr.get_colorblind_mode_setting():
		#colorblind_btn.text = "Readable Colors: ON"
	#else:
		#colorblind_btn.text = "Readable Colors: OFF"


#func update_text() -> void:
	#pass
	#if GameMgr.get_reduce_motion_setting():
		#pause_info.text = GameplayUI.BBCODE_TXT_NO_MOTION + PAUSE_INFO_BEGIN + str(GameMgr.checkerboard_id) + "-" + str(GameMgr.board_id) + PAUSE_INFO_END
	#else:
		#pause_info.text = GameplayUI.BBCODE_TXT + PAUSE_INFO_BEGIN + str(GameMgr.checkerboard_id) + "-" + str(GameMgr.board_id) + PAUSE_INFO_END
		
