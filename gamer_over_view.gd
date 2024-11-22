extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func show_game_over():
	show()


func _on_reset_button_pressed() -> void:
	hide()
	# Obtén la ruta de la escena actual
	# Cambia la escena a sí misma
	get_tree().change_scene_to_file("res://levels/level_0.tscn")


func _on_back_to_menu_pressed():
	get_tree().change_scene_to_file("res://menu.tscn")
