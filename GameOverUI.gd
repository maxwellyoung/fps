extends CanvasLayer

@onready var restart_button: Button = $Button

func _ready():
	# Connect the button's "pressed" signal to our restart function.
	restart_button.pressed.connect(on_restart_pressed)
	# Hide the screen by default.
	hide()

func show_game_over():
	show()
	# Pause the game and show the mouse cursor.
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func on_restart_pressed():
	# Unpause the game and reload the current level.
	get_tree().paused = false
	get_tree().reload_current_scene() 
