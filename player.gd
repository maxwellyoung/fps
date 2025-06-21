extends CharacterBody3D

signal health_changed(new_health)
signal ammo_changed(new_ammo)

@export var max_health := 100.0
var current_health: float

@export var max_ammo := 12
var current_ammo: int

@export var speed := 5.0
@export var sprint_speed := 8.0
@export var mouse_sens := Vector2(0.003, 0.003)

var yaw := 0.0
var pitch := 0.0

@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var jump_velocity := 4.5

@onready var muzzle_flash: GPUParticles3D = $SpringArm3D/Camera3D/MuzzleFlash
@onready var gunshot_sound: AudioStreamPlayer3D = $SpringArm3D/Camera3D/GunshotSound
@onready var raycast: RayCast3D = $SpringArm3D/Camera3D/RayCast3D

@export var game_over_ui: PackedScene
@export var impact_effect: PackedScene

@export var range := 100.0
@export var damage := 25

func _ready():
	current_health = max_health
	current_ammo = max_ammo
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func take_damage(amount):
	current_health = max(0, current_health - amount)
	health_changed.emit(current_health)
	if current_health <= 0:
		die()

func die():
	print("Player has died!")
	if game_over_ui:
		var ui_instance = game_over_ui.instantiate()
		add_child(ui_instance)
		ui_instance.show_game_over()

func _unhandled_input(ev):
	if ev is InputEventMouseMotion:
		yaw -= ev.relative.x * mouse_sens.x
		pitch = clamp(pitch - ev.relative.y * mouse_sens.y, deg_to_rad(-80), deg_to_rad(80))
		rotation.y = yaw
		$SpringArm3D.rotation.x = pitch

func _physics_process(delta):
	# Handle player actions
	if Input.is_action_just_pressed("fire"):
		shoot()
	if Input.is_action_just_pressed("reload"):
		reload_weapon()

	# Add gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get input direction.
	var dir := Vector3.ZERO
	dir.z = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	dir = global_transform.basis * dir.normalized()

	# Apply horizontal velocity.
	var horizontal_velocity = velocity
	horizontal_velocity.y = 0
	
	var target_speed = speed
	if Input.is_action_pressed("sprint"):
		target_speed = sprint_speed
	
	var target = dir * target_speed
	
	# Smooth acceleration (floaty controls)
	# horizontal_velocity = horizontal_velocity.lerp(target, delta * 10.0)
	
	# Snappy controls
	horizontal_velocity = target
	
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z

	move_and_slide()

func shoot():
	if current_ammo <= 0:
		return # Can't shoot with no ammo.

	current_ammo -= 1
	ammo_changed.emit(current_ammo)
	
	if muzzle_flash:
		muzzle_flash.restart()
	if gunshot_sound:
		gunshot_sound.play()
	
	raycast.target_position = Vector3(0, 0, -range)
	raycast.force_raycast_update()
	if raycast.is_colliding():
		var impact_point = raycast.get_collision_point()
		var impact_normal = raycast.get_collision_normal()
		
		if impact_effect:
			var impact_instance = impact_effect.instantiate()
			get_tree().get_root().add_child(impact_instance)
			impact_instance.global_position = impact_point
			impact_instance.look_at(impact_point + impact_normal, Vector3.UP)

		var obj = raycast.get_collider()
		if obj.has_method("hit"):
			obj.hit(damage)

func reload_weapon():
	current_ammo = max_ammo
	ammo_changed.emit(current_ammo)


