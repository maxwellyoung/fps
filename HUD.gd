extends CanvasLayer

@onready var health_bar: ProgressBar = $ProgressBar
@onready var ammo_label: Label = $Label

func _ready():
	# This will be called by the player script when the game starts.
	pass

# This function is called when the player's "health_changed" signal is emitted.
func _on_player_health_changed(new_health):
	health_bar.value = new_health

# This function is called when the player's "ammo_changed" signal is emitted.
func _on_player_ammo_changed(new_ammo):
	ammo_label.text = "Ammo: %s" % new_ammo 
