extends Node2D

# 지형 생성기
var terrain_gen: TerrainGenerator

# 생성할 지형 범위
@export var terrain_start_x: float = 0.0
@export var terrain_width: float = 2000.0
@export var sample_interval: int = 10

# 지형 파라미터 (Inspector에서 조정 가능)
@export_group("Terrain Parameters")
@export var frequency: float = 0.02
@export var amplitude: float = 100.0
@export var ground_level: float = 300.0
@export var terrain_seed: int = 42

func _ready():
	generate_terrain()

func generate_terrain():
	# 기존 지형 제거
	for child in get_children():
		child.queue_free()
	
	# 지형 생성기 초기화
	terrain_gen = TerrainGenerator.new({
		"frequency": frequency,
		"amplitude": amplitude,
		"ground_level": ground_level,
		"seed": terrain_seed
	})
	
	# 높이 데이터 생성
	var heights = terrain_gen.generate_heights(terrain_start_x, terrain_width, sample_interval)
	
	if heights.size() == 0:
		push_error("지형 생성 실패")
		return
	
	# 시각화
	draw_terrain_line(heights)
	
	# 물리 충돌
	setup_collision(heights)
	
	print("지형 생성 완료: %d 포인트" % heights.size())

# Line2D로 지형 그리기
func draw_terrain_line(heights: Array):
	var line = Line2D.new()
	line.name = "TerrainLine"
	line.points = terrain_gen.heights_to_points(heights)
	line.width = 3.0
	line.default_color = Color.WHITE
	add_child(line)

# StaticBody2D + CollisionPolygon2D로 물리 충돌 설정
func setup_collision(heights: Array):
	var body = StaticBody2D.new()
	body.name = "TerrainCollision"
	
	var collision = CollisionPolygon2D.new()
	collision.polygon = terrain_gen.create_collision_polygon(heights, 1000.0)
	
	body.add_child(collision)
	add_child(body)

# Inspector에서 파라미터 변경 시 재생성
func _on_parameter_changed():
	if Engine.is_editor_hint():
		return
	generate_terrain()
