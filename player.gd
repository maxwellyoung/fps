extends CharacterBody3D

@export var speed := 5.0
@export var mouse_sens := Vector2(0.003, 0.003)

var yaw := 0.0
var pitch := 0.0

@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var range := 100.0
@export var damage := 25

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(ev):
	if ev is InputEventMouseMotion:
		yaw -= ev.relative.x * mouse_sens.x
		pitch = clamp(pitch - ev.relative.y * mouse_sens.y, deg_to_rad(-80), deg_to_rad(80))
		rotation.y = yaw
		$SpringArm3D.rotation.x = pitch

func _physics_process(delta):
	# Add gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Get input direction.
	var dir := Vector3.ZERO
	dir.z = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	dir = global_transform.basis * dir.normalized()

	# Apply horizontal velocity.
	var horizontal_velocity = velocity
	horizontal_velocity.y = 0
	
	var target = dir * speed
	
	# Smooth acceleration.
	horizontal_velocity = horizontal_velocity.lerp(target, delta * 10.0)
	
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z

	move_and_slide()

func _input(ev):
	if ev.is_action_pressed("fire"):
		$RayCast3D.target_position = Vector3(0, 0, -range)
		$RayCast3D.force_raycast_update()
		if $RayCast3D.is_colliding():
			var obj = $RayCast3D.get_collider()
			if obj.has_method("hit"):
				obj.hit(damage) 
