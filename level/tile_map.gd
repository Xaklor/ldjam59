extends TileMapLayer

var astar: AStarGrid2D
var loot_map: Array[Array]

func initialize():
	astar = AStarGrid2D.new()
	var map_end = get_used_rect().end
	astar.region = Rect2i(Vector2i.ZERO, map_end)
	astar.cell_size = tile_set.tile_size
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()
	
	for i in map_end.x:
		for j in map_end.y:
			var pos = Vector2i(i, j)
			if get_cell_tile_data(pos).get_custom_data("solid"):
				astar.set_point_solid(pos)
	
	loot_map = []
	for x in range(astar.region.end.x):
		loot_map.append([])
		for y in range(astar.region.end.y):
			loot_map[x].append(null)
