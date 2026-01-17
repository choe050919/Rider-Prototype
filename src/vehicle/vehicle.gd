extends Node2D

@onready var front_wheel = $FrontWheel
@onready var rear_wheel = $RearWheel
@onready var front_ray = $FrontWheel/RayCast2D
@onready var rear_ray = $RearWheel/RayCast2D

@export var drive_force: float = 3000.0

func _physics_process(delta):
	handle_input()

func handle_input():
	var force = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		force.x = drive_force
	
	if Input.is_action_pressed("ui_left"):
		force.x = -drive_force
	
	if force != Vector2.ZERO:
		# 접지된 바퀴에만 힘 적용
		if front_ray.is_colliding():
			front_wheel.apply_force(force)
		
		if rear_ray.is_colliding():
			rear_wheel.apply_force(force)
