class_name TerrainGenerator
extends RefCounted

var noise_field: NoiseField

# 지형 생성 파라미터
var frequency: float = 0.02
var amplitude: float = 100.0
var ground_level: float = 300.0  # 기본 높이
var seed_value: int = 42

func _init(params: Dictionary = {}):
	# 파라미터 오버라이드
	if params.has("frequency"):
		frequency = params.frequency
	if params.has("amplitude"):
		amplitude = params.amplitude
	if params.has("ground_level"):
		ground_level = params.ground_level
	if params.has("seed"):
		seed_value = params.seed
	
	# NoiseField 초기화
	var spec = NoiseSpec.new()
	spec.seed = seed_value
	spec.frequency = frequency
	spec.amplitude = amplitude
	spec.bias = ground_level
	
	noise_field = NoiseField.new(spec)

# 지형 높이 배열 생성
# start_x: 시작 x 좌표
# width: 생성할 너비
# sample_interval: 샘플링 간격 (픽셀 단위)
func generate_heights(start_x: float, width: float, sample_interval: int = 5) -> Array:
	var heights = []
	var x = start_x
	
	while x < start_x + width:
		var height = noise_field.sample2(Vector2(x, 0))
		heights.append({"x": x, "y": height})
		x += sample_interval
	
	return heights

# 높이 배열을 PackedVector2Array로 변환
func heights_to_points(heights: Array) -> PackedVector2Array:
	var points = PackedVector2Array()
	for h in heights:
		points.append(Vector2(h.x, h.y))
	return points

# 지형 폴리곤 생성 (충돌용)
# 지형 곡선 + 바닥을 감싸는 폴리곤
func create_collision_polygon(heights: Array, bottom_y: float = 1000.0) -> PackedVector2Array:
	var polygon = PackedVector2Array()
	
	# 지형 곡선 추가
	for h in heights:
		polygon.append(Vector2(h.x, h.y))
	
	# 바닥 폴리곤 닫기
	if heights.size() > 0:
		var last = heights[-1]
		var first = heights[0]
		polygon.append(Vector2(last.x, bottom_y))  # 오른쪽 아래
		polygon.append(Vector2(first.x, bottom_y))  # 왼쪽 아래
	
	return polygon
