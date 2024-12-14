extends Control

const LINES := [
	"This was a demo",
	"Thank you for reading <3"
]

func _ready() -> void:
	$White.modulate.a = 0.0
	$Black.modulate.a = 0.0
	$Label.modulate.a = 0.0
	$White.visible = true
	$Black.visible = true
	$Label.visible = true
	visible = true
	
	for screen : Control in $Screens.get_children():
		for part : TextureRect in screen.get_children():
			part.visible = false

func start():
	Sound.play_sfx("shutter")
	await get_tree().create_timer(0.5).timeout
	#Parser.line_reader.instruction_handler.set_sun("steps", 3.7)
	#await get_tree().create_timer(1.5).timeout
	#Parser.line_reader.instruction_handler.set_sun("fill_amount", 6.5)
	#await get_tree().create_timer(1.5).timeout
	#Parser.line_reader.instruction_handler.set_sun("steps", 1.8)
	#await get_tree().create_timer(0.5).timeout
	
	
	var black_tween = create_tween()
	black_tween.tween_property($Black, "modulate:a", 1.0, 0.0)
	Sound.play_sfx("shutter")
	GameWorld.game_stage.hide_cg()
	
	await black_tween.finished
	
	await get_tree().create_timer(2.0).timeout
	
	for screen : Control in $Screens.get_children():
		for part : TextureRect in screen.get_children():
			await get_tree().create_timer(1).timeout
			part.visible = true
			Sound.play_sfx("click")
		
		if screen != $Screens.get_children().back():
			await get_tree().create_timer(3).timeout
			screen.visible = false
			Sound.play_sfx("shutter")
			await get_tree().create_timer(1).timeout
