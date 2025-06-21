extends Area3D

@export var damage_per_second := 25.0

func _on_body_entered(body):
	# We will connect this to the Area3D's signal in the editor.
	# This function is called whenever a physics body (like a player) enters the zone.
	pass # For now, we'll just check if it enters.


func _on_body_exited(body):
	# We will also connect this to the "body_exited" signal.
	pass


func _physics_process(delta):
	# Get a list of all bodies currently inside the area.
	var overlapping_bodies = get_overlapping_bodies()
	
	for body in overlapping_bodies:
		if body.has_method("take_damage"):
			body.take_damage(damage_per_second * delta) 
