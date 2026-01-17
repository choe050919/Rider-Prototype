class_name TerrainManager
extends Node2D

# 추적할 대상 (공)
@export var target: Node2D

# 청크 설정
@export var chunk_width: float = 500.0  # 청크 하나의 너비
@export var load_distance: int = 3  # 좌우로 유지할 청크 개수
@export var sample_interval: int = 10  # 샘플링 간격

# 지형 생성 파라미터
@export_group("Terrain Parameters")
@export var frequency: float = 0.02
@export var amplitude: float = 100.0
@export var ground_level: float = 300.0
@export var terrain_seed: int = 42

# 내부 상태
var terrain_gen: TerrainGenerator
var active_chunks: Dictionary = {}  # chunk_index -> Node2D
var last_chunk_index: int = 0

func _ready():
	print("TerrainManager _ready()")
	print("Target: ", target)
	
	# 지형 생성기 초기화
	terrain_gen = TerrainGenerator.new({
		"frequency": frequency,
		"amplitude": amplitude,
		"ground_level": ground_level,
		"seed": terrain_seed
	})
	
	print("TerrainGenerator created")
	
	# 초기 청크 생성
	if target:
		print("Target exists, updating chunks")
		update_chunks()
	else:
		print("WARNING: No target set!")

func _process(delta):
	if target:
		var current_chunk = get_chunk_index(target.global_position.x)
		if current_chunk != last_chunk_index:
			update_chunks()
			last_chunk_index = current_chunk

# 위치에서 청크 인덱스 계산
func get_chunk_index(x_position: float) -> int:
	return int(floor(x_position / chunk_width))

# 청크 업데이트
func update_chunks():
	var center_chunk = get_chunk_index(target.global_position.x)
	
	# 필요한 청크 범위
	var needed_chunks = {}
	for i in range(-load_distance, load_distance + 1):
		needed_chunks[center_chunk + i] = true
	
	# 불필요한 청크 제거
	var to_remove = []
	for chunk_idx in active_chunks.keys():
		if not needed_chunks.has(chunk_idx):
			to_remove.append(chunk_idx)
	
	for chunk_idx in to_remove:
		remove_chunk(chunk_idx)
	
	# 새 청크 생성
	for chunk_idx in needed_chunks.keys():
		if not active_chunks.has(chunk_idx):
			create_chunk(chunk_idx)

# 청크 생성
func create_chunk(chunk_index: int):
	print("Creating chunk: ", chunk_index)
	
	var chunk_node = Node2D.new()
	chunk_node.name = "Chunk_%d" % chunk_index
	
	var start_x = chunk_index * chunk_width
	var heights = terrain_gen.generate_heights(start_x, chunk_width, sample_interval)
	
	print("  Heights generated: ", heights.size(), " points")
	
	if heights.size() == 0:
		print("  WARNING: No heights generated!")
		return
	
	# 시각화
	var line = Line2D.new()
	line.name = "TerrainLine"
	line.points = terrain_gen.heights_to_points(heights)
	line.width = 3.0
	line.default_color = Color.WHITE
	chunk_node.add_child(line)
	
	# 물리 충돌
	var body = StaticBody2D.new()
	body.name = "TerrainCollision"
	
	var collision = CollisionPolygon2D.new()
	collision.polygon = terrain_gen.create_collision_polygon(heights, 1000.0)
	body.add_child(collision)
	chunk_node.add_child(body)
	
	add_child(chunk_node)
	active_chunks[chunk_index] = chunk_node

# 청크 제거
func remove_chunk(chunk_index: int):
	if active_chunks.has(chunk_index):
		var chunk = active_chunks[chunk_index]
		chunk.queue_free()
		active_chunks.erase(chunk_index)
