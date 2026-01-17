extends Polygon2D

@export var radius: float = 15.0
@export var segments: int = 32

func _ready():
	draw_circle_polygon()

func draw_circle_polygon():
	var points = PackedVector2Array()
	
	for i in range(segments):
		var angle = (i / float(segments)) * TAU
		var point = Vector2(cos(angle), sin(angle)) * radius
		points.append(point)
	
	self.polygon = points
	self.color = Color.WHITE
