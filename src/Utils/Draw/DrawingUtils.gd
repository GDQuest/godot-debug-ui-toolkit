# Drawing utilities for tool scripts in the viewport or in-game visual debugging
# Use sprites, SVG shapes, or meshes instead of drawing from the code whenever possible

const ELIPSE_FILL: SphereMesh = preload("res://src/Utils/Draw/elipse.tres")
const ELIPSE_OUTLINE: SphereMesh = preload("res://src/Utils/Draw/elipse_outline.tres")

const DEFAULT_POINTS_COUNT : = 32

static func draw_circle_outline(canvas_item: CanvasItem, radius: float, color := Color.white, offset := Vector2.ZERO, thickness := 1.0) -> void:
	var points_array : = PoolVector2Array()
	for i in range(DEFAULT_POINTS_COUNT + 1):
		var angle : = 2 * PI * i / DEFAULT_POINTS_COUNT
		var point : = offset + Vector2(cos(angle) * radius, sin(angle) * radius)
		points_array.append(point)
	canvas_item.draw_polyline(points_array, color, thickness, true)


static func draw_triangle(canvas_item: CanvasItem, center: Vector2, size: float, angle: float, color: Color, draw_outline := false, outline_width := 4.0, outline_color := Color.white) -> void:
	var colors : PoolColorArray
	for i in range(3):
		colors.append(color)
	
	var points : PoolVector2Array
	for i in range(3):
		var point := Vector2.ZERO
		point.y -= size
		point = point.rotated(TAU / 3 * i)
		point = point.rotated(angle)
		point += center
		points.append(point)
	if draw_outline:
		draw_triangle(canvas_item, center, size + outline_width, angle, outline_color)
	canvas_item.draw_polygon(points, colors)


static func draw_vector(canvas_item: CanvasItem, start: Vector2, end: Vector2, width: float, tip_size: float, color: Color, draw_outline := false, outline_width := 4.0, outline_color := Color.white) -> void:
	if draw_outline:
		draw_vector(canvas_item, start, end, width + outline_width, tip_size + outline_width, outline_color)
	var angle = start.angle_to(end) + (PI / 2)
	draw_triangle(canvas_item, end, tip_size, angle, color)
	canvas_item.draw_line(start, end, color, width)


static func draw_arc(canvas_item: CanvasItem, center: Vector2, radius: float, start_angle: float, end_angle: float, point_count: int, color: Color, width: float, draw_outline := false, outline_width := 4.0, outline_color := Color.white) -> void:
	if draw_outline:
		draw_arc(canvas_item, center, radius, start_angle, end_angle, point_count, outline_color, width + outline_width)
	canvas_item.draw_arc(center, radius, start_angle, end_angle, point_count, color, width)


static func draw_elipse(canvas_item: CanvasItem, center: Vector2, radius: float, height: float, color := Color.white, draw_outline := false, outline_width := 4.0, outline_color := Color.white, elipse_path = ELIPSE_FILL.resource_path) -> void:
	var elipse_mesh := load(elipse_path)
	elipse_mesh.radius = radius * 0.5
	elipse_mesh.height = height
	var transform := Transform2D(Vector2.RIGHT, Vector2.DOWN, Vector2.ZERO)
	
	if draw_outline:
		draw_elipse(canvas_item, center, radius + outline_width, height + outline_width, outline_color, false, outline_width, outline_color, ELIPSE_OUTLINE.resource_path)
	
	canvas_item.draw_mesh(elipse_mesh, null, null, transform, color)


static func draw_grid(canvas_item: CanvasItem, grid_origin: Vector2, cell_size: Vector2, cell_amount: Vector2, width: float, color := Color.white) -> void:
	for cell in cell_amount.x:
		var rect_x := Rect2(grid_origin.x + (cell_size.x * cell), grid_origin.y, cell_size.x, cell_size.y)
		canvas_item.draw_rect(rect_x, color, false, width)
		for cell in cell_amount.y:
			var rect_y := Rect2(rect_x.position.x, rect_x.position.y + (cell_size.y * cell), cell_size.x, cell_size.y)
			canvas_item.draw_rect(rect_y, color, false, width)


static func draw_grid_cell(canvas_item: CanvasItem, grid_origin: Vector2, cell_size: Vector2, cell: Vector2, isometric := false, color := Color.white, draw_outline := false, outline_width := 4.0, outline_color := Color.white) -> void:
	if draw_outline:
		draw_grid_cell(canvas_item, grid_origin, cell_size + Vector2(outline_width, outline_width), cell, isometric, outline_color)
	var rect := Rect2(grid_origin + (cell_size * cell), cell_size)
	canvas_item.draw_rect(rect, color, true)


static func draw_isometric_grid(canvas_item: CanvasItem, grid_origin: Vector2, cell_size: Vector2, cell_amount: Vector2, width: float, color := Color.white) -> void:
	var outer_rect := Rect2(grid_origin, cell_size * cell_amount)
	canvas_item.draw_rect(outer_rect, color, false, width)
	for cell in cell_amount.x:
		var rect_x := Rect2(grid_origin.x + (cell_size.x * cell), grid_origin.y, cell_size.x, cell_size.y)
		canvas_item.draw_line(rect_x.position, rect_x.end, color, width)
		canvas_item.draw_line(Vector2(rect_x.end.x, rect_x.position.y), Vector2(rect_x.position.x, rect_x.end.y), color, width)
		for cell in cell_amount.y:
			var rect_y := Rect2(rect_x.position.x, rect_x.position.y + (cell_size.y * cell), cell_size.x, cell_size.y)
			canvas_item.draw_line(rect_y.position, rect_y.end, color, width)
			canvas_item.draw_line(Vector2(rect_y.end.x, rect_y.position.y), Vector2(rect_y.position.x, rect_y.end.y), color, width)


static func draw_isometric_cell(canvas_item: CanvasItem, grid_origin: Vector2, cell_size: Vector2, cell: Vector2, color := Color.white, draw_outline := false, outline_width := 0.0, outline_color := Color.white) -> void:
	var colors : PoolColorArray
	for i in range(4):
		colors.append(color)
	
	var points : PoolVector2Array
	for i in range(4):
		var point := Vector2.ZERO
		point.x += cell_size.x * 0.5
		point = point.rotated(TAU / 4 * i)
		if not i % 2 == 0:
			point *= cell_size.y / cell_size.x
		var offset = cell * cell_size
		point += offset
		point.x += cell_size.x * 0.5
		points.append(point)
	
	if draw_outline:
		_draw_isometric_cell_outline(canvas_item, grid_origin, cell_size, cell, outline_color, outline_width)
	canvas_item.draw_polygon(points, colors)


# Method to workaround the cell outline drawing, it adds an extra offset based on the `outline_width`
static func _draw_isometric_cell_outline(canvas_item: CanvasItem, grid_origin: Vector2, cell_size: Vector2, cell: Vector2, color := Color.white, outline_width := 4.0) -> void:
	var colors : PoolColorArray
	for i in range(4):
		colors.append(color)
	
	var points : PoolVector2Array
	for i in range(4):
		var point := Vector2.ZERO
		point.x += cell_size.x * 0.5
		point.x += outline_width
		point = point.rotated(TAU / 4 * i)
		if not i % 2 == 0:
			point *= cell_size.y / cell_size.x
		var offset = cell * cell_size
		point += offset
		point.x += cell_size.x * 0.5
		points.append(point)
	
	canvas_item.draw_polygon(points, colors)
