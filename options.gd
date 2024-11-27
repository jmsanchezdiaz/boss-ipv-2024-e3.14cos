extends Control

@onready var masterSlider: HSlider = $Master/MasterSlider
@onready var zombiesSlider: HSlider = $Zombies/ZombiesSlider
@onready var musicSlider: HSlider = $Music/MusicSlider
@onready var playerSlider: HSlider = $Player/PlayerSlider


func _ready() -> void:
	hide()
	masterSlider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	zombiesSlider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Zombie")))
	musicSlider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Musica")))
	playerSlider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Player")))

func toggle_pause() -> void:
	if get_tree().paused:
		get_tree().paused = false
		visible = false;
	else:
		get_tree().paused = true
		visible = true;

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("escape"):  
		toggle_pause()
	
	

func _on_button_pressed() -> void:
	toggle_pause()


func _on_master_slider_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
	
func _on_music_slider_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Musica"), linear_to_db(value))
	
func _on_player_slider_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Player"), linear_to_db(value))
	
func _on_zombie_slider_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Zombie"), linear_to_db(value))
