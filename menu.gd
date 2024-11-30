extends Node2D

@onready var controls = $CanvasLayer/Controls
@onready var controlsBg = $CanvasLayer/ControlsBG
@onready var options = $CanvasLayer/Options
@onready var music = $Musica
@onready var optionsBtn = $CanvasLayer/OptionsBtn


# Called when the node enters the scene tree for the first time.
func _ready():
	music.play(10.0)
	controls.hide()
	controlsBg.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_btn_pressed():
	get_tree().change_scene_to_file("res://Intro.tscn")


func _on_controls_btn_pressed():
	controls.show()
	controlsBg.show()


func _on_close_controls_button_pressed():
	controls.hide()
	controlsBg.hide()


func _on_options_btn_pressed() -> void:
	optionsBtn.release_focus()
	options.show()


func _on_e_xit_pressed() -> void:
	get_tree().quit()
