extends TileMapLayer

var astar = AStarGrid2D.new()
var loot_map: Array[Array]

func _ready():
	var tilemap_size = get_used_rect().end - get_used_rect().position
	astar.region = Rect2i(Vector2i.ZERO, tilemap_size)
	astar.cell_size = tile_set.tile_size
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()
	
	for i in tilemap_size.x:
		for j in tilemap_size.y:
			var pos = Vector2i(i, j)
			if get_cell_tile_data(pos).get_custom_data("tile_type") == "wall":
				astar.set_point_solid(pos)
	
	loot_map = []
	for x in astar.region.end.x:
		loot_map.append([])
		for y in astar.region.end.y:
			loot_map[x].append(null)
