extends Polygon2D

@export var width: float = 80.0
@export var height: float = 40.0

func _ready():
	draw_box()

func draw_box():
	var half_w = width / 2
	var half_h = height / 2
	
	self.polygon = PackedVector2Array([
		Vector2(-half_w, -half_h),
		Vector2(half_w, -half_h),
		Vector2(half_w, half_h),
		Vector2(-half_w, half_h)
	])
	self.color = Color(0.8, 0.8, 0.8, 1.0)  # 회색
