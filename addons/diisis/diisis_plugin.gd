@tool
extends EditorPlugin
class_name DIISISPlugin

var dia_editor_window:Window
var toolbar_button

#const AUTOLOAD_DATA = "Data"
const AUTOLOAD_PAGES = "Pages"
const AUTOLOAD_PARSER = "Parser"
const AUTOLOAD_EDITOR_ACTIONS = "DiisisEditorActions"
const AUTOLOAD_EDITOR_UTIL = "DiisisEditorUtil"
const AUTOLOAD_PARSER_EVENTS = "ParserEvents"
const AUTOLOAD_SHARED_DIISIS = "DIISIS"


func add_editor_singletons():
	#if OS.has_feature("web"):
		#return
	add_autoload_singleton(AUTOLOAD_PAGES, "res://addons/diisis/editor/autoload/pages.tscn")
	add_autoload_singleton(AUTOLOAD_EDITOR_UTIL, "res://addons/diisis/editor/autoload/diisis_editor_util.tscn")
	add_autoload_singleton(AUTOLOAD_EDITOR_ACTIONS, "res://addons/diisis/editor/autoload/diisis_editor_actions.tscn")

func add_parser_singletons():
	add_autoload_singleton(AUTOLOAD_PARSER, "res://addons/diisis/parser/autoload/parser.tscn")
	add_autoload_singleton(AUTOLOAD_PARSER_EVENTS, "res://addons/diisis/parser/autoload/parser_events.tscn")

func remove_editor_singletons():
	#if OS.has_feature("web"):
		#return
	remove_autoload_singleton(AUTOLOAD_PAGES)
	remove_autoload_singleton(AUTOLOAD_EDITOR_UTIL)
	remove_autoload_singleton(AUTOLOAD_EDITOR_ACTIONS)

func remove_parser_singletons():
	remove_autoload_singleton(AUTOLOAD_PARSER)
	remove_autoload_singleton(AUTOLOAD_PARSER_EVENTS)

func _enter_tree():
	if not ProjectSettings.has_setting("diisis/project/file/path"):
		ProjectSettings.set_setting("diisis/project/file/path", "")
		ProjectSettings.save()
	add_autoload_singleton(AUTOLOAD_SHARED_DIISIS, "res://addons/diisis/shared/autoload/Diisis.tscn")
	add_editor_singletons()
	add_parser_singletons()
	add_custom_type("LineReader", "Control", preload("res://addons/diisis/parser/src/line_reader.gd"), preload("res://addons/diisis/parser/style/reader_icon_Zeichenfläche 1.svg"))
	add_custom_type("InstructionHandler", "Node", preload("res://addons/diisis/parser/src/line_reader.gd"), preload("res://addons/diisis/parser/style/reader_icon_Zeichenfläche 1.svg"))

	if not OS.has_feature("editor"):
		return
	
	var root := DirAccess.open("res://")
	if not root.dir_exists("addons/diisis/files"):
		root.make_dir("addons/diisis/files")
	
	toolbar_button = preload("res://addons/diisis/editor/open_editor_button.tscn").instantiate()
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, toolbar_button)
	toolbar_button.visible = true
	toolbar_button.is_in_editor = true
	toolbar_button.pressed.connect(open_editor)
	toolbar_button.request_open_diisis.connect(open_editor)
	
	
	await get_tree().process_frame
	toolbar_button.get_parent().move_child(toolbar_button, -2)
	

	var welcome_message := "[font=res://addons/diisis/editor/visuals/fonts/Comfortaa-Regular.ttf]"
	welcome_message += "Thank you for using [hint=Dialog Interface Sister System]DIISIS[/hint]! Feel free to reach out on GitHub with any bugs you encounter and features you yearn for :3"
	print_rich(welcome_message)
	
func open_editor():
	if is_instance_valid(dia_editor_window):
		dia_editor_window.grab_focus()
	else:
		remove_editor_singletons()
		add_editor_singletons()
		dia_editor_window = preload("res://addons/diisis/editor/dialog_editor_window.tscn").instantiate()
		get_editor_interface().get_base_control().add_child.call_deferred(dia_editor_window)
		
		var project_file_path : String = ProjectSettings.get_setting("diisis/project/file/path")
		if FileAccess.file_exists(project_file_path) and not project_file_path.is_empty():
			dia_editor_window.file_path = project_file_path
		
		await get_tree().process_frame
		dia_editor_window.popup()
		dia_editor_window.open_new_file.connect(open_new_file)

func open_new_file():
	remove_editor_singletons()
	add_editor_singletons()
	dia_editor_window = preload("res://addons/diisis/editor/dialog_editor_window.tscn").instantiate()
	get_editor_interface().get_base_control().add_child.call_deferred(dia_editor_window)
	dia_editor_window.file_path = ""
	await get_tree().process_frame
	dia_editor_window.popup()
	dia_editor_window.open_new_file.connect(open_new_file)

func _process(delta: float) -> void:
	if is_instance_valid(dia_editor_window):
		dia_editor_window.wrap_controls = true

func _exit_tree():
	remove_editor_singletons()
	remove_parser_singletons()
	remove_autoload_singleton(AUTOLOAD_SHARED_DIISIS)
	if dia_editor_window:
		dia_editor_window.queue_free()
	remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, toolbar_button)
