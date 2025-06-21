extends CanvasLayer

@onready var health_bar: ProgressBar = $ProgressBar

# This function is called when the player's "health_changed" signal is emitted.
func _on_player_health_changed(new_health):
	health_bar.value = new_health 
