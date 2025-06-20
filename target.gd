extends RigidBody3D

@export var health := 100.0

# This function is called by the player's script when the raycast hits.
func hit(damage_amount):
	health -= damage_amount
	print("Target hit! Remaining health: ", health)
	if health <= 0:
		print("Target destroyed!")
		queue_free() # This will make the target disappear. 