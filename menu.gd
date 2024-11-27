extends Node2D

@onready var controls = $CanvasLayer/Controls
@onready var options = $CanvasLayer/Options
@onready var music = $Musica
@onready var optionsBtn = $CanvasLayer/OptionsBtn


# Called when the node enters the scene tree for the first time.
func _ready():
	music.play(10.0)
	controls.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_btn_pressed():
	get_tree().change_scene_to_file("res://levels/level_0.tscn")


func _on_controls_btn_pressed():
	controls.show()


func _on_close_controls_button_pressed():
	controls.hide()


func _on_options_btn_pressed() -> void:
	optionsBtn.release_focus()
	options.show()
