extends RigidBody2D

# 공을 미는 힘
@export var push_force: float = 5000.0

func _physics_process(delta):
	# 오른쪽 키
	if Input.is_action_pressed("ui_right"):
		apply_force(Vector2(push_force, 0))
	
	# 왼쪽 키
	if Input.is_action_pressed("ui_left"):
		apply_force(Vector2(-push_force, 0))
