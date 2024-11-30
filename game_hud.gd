extends CanvasLayer

@onready var optionsBtn = $GameOver/OptionsBtn
@onready var gameOverView = $GameOver
@onready var options = $Options

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gameOverView.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func show_game_over():
	gameOverView.show()


func _on_reset_button_pressed() -> void:
	hide()
	# Obtén la ruta de la escena actual
	# Cambia la escena a sí misma
	get_tree().change_scene_to_file("res://levels/level_0.tscn")


func _on_back_to_menu_pressed():
	get_tree().change_scene_to_file("res://menu.tscn")


func _on_options_btn_pressed() -> void:
	optionsBtn.release_focus()
	options.show()
	


func _on_exit_pressed() -> void:
	get_tree().quit()
