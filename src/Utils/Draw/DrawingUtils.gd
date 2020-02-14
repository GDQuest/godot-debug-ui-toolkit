# Drawing utilities for tool scripts in the viewport or in-game visual debugging
class_name DrawingUtils2D
extends Node2D


const DEFAULT_POINTS_COUNT := 32


func draw_circle_outline(
		radius: float,
		color := Color.white,
		offset := Vector2.ZERO,
		thickness := 1.0
	) -> void:
	var points := PoolVector2Array()
	for i in range(DEFAULT_POINTS_COUNT + 1):
		var angle := 2 * PI * i / DEFAULT_POINTS_COUNT
		var point := offset + Vector2(cos(angle) * radius, sin(angle) * radius)
		points.append(point)
	draw_polyline(points, color, thickness, true)


func draw_triangle(
		center: Vector2,
		radius: float,
		angle: float,
		color: Color,
		use_outline := false,
		outline_width := 4.0,
		outline_color := Color.white
	) -> void:
	var colors : PoolColorArray
	for i in range(3):
		colors.append(color)

	var points : PoolVector2Array
	for i in range(3):
		var point := Vector2.ZERO
		point.y -= radius
		point = point.rotated(TAU / 3 * i)
		point = point.rotated(angle)
		point += center
		points.append(point)
	if use_outline:
		draw_triangle(center, radius + outline_width, angle, outline_color)
	draw_polygon(points, colors)


func draw_vector(
		start: Vector2,
		end: Vector2,
		width: float,
		tip_size: float,
		color: Color,
		use_outline := false,
		outline_width := 4.0,
		outline_color := Color.white
	) -> void:
	if use_outline:
		draw_vector(start, end, width + outline_width, tip_size + outline_width, outline_color)
	var angle = start.angle_to(end) + (PI / 2)
	draw_triangle(end, tip_size, angle, color)
	draw_line(start, end, color, width)


func draw_circle_arc(
		center: Vector2,
		radius: float,
		angle_start: float,
		angle_end: float,
		point_count: int,
		color: Color,
		width: float,
		use_outline := false,
		outline_width := 4.0,
		outline_color := Color.white
	) -> void:
	if use_outline:
		draw_arc(center, radius, angle_start, angle_end, point_count, outline_color, width + outline_width)
	draw_arc(center, radius, angle_start, angle_end, point_count, color, width)


func draw_ellipse(
		axis_major := 1.0,
		axis_minor := 1.0,
		center := Vector2.ZERO,
		theta := 0.0,
		colors := PoolColorArray([Color.white]),
		use_outline := false,
		outline_width := 4.0,
		outline_color := Color.white,
		resolution := DEFAULT_POINTS_COUNT
	) -> void:
	var points := PoolVector2Array()
	for i in range(resolution + 1):
		var angle := float(i) / resolution * 2.0 * PI
		var point := center + Vector2(
				axis_major * cos(angle),
				axis_minor * sin(angle)
			).rotated(theta)
		points.append(point)
	draw_polygon(points, colors)
	if use_outline:
		draw_ellipse(axis_major, axis_minor, center, theta, colors, false, outline_width, outline_color, resolution)


func draw_grid(
		grid_origin: Vector2,
		cell_size: Vector2,
		grid_size: Vector2,
		width: float,
		color := Color.white
	) -> void:
	for cell in grid_size.x:
		var rect_x := Rect2(grid_origin.x + (cell_size.x * cell), grid_origin.y, cell_size.x, cell_size.y)
		draw_rect(rect_x, color, false, width)
		for cell in grid_size.y:
			var rect_y := Rect2(rect_x.position.x, rect_x.position.y + (cell_size.y * cell), cell_size.x, cell_size.y)
			draw_rect(rect_y, color, false, width)


func draw_grid_cell(
		grid_origin: Vector2,
		size: Vector2,
		cell_coordinates: Vector2,
		color := Color.white,
		use_outline := false,
		outline_width := 4.0,
		outline_color := Color.white
	) -> void:
	if use_outline:
		draw_grid_cell(grid_origin, size + Vector2(outline_width, outline_width), cell_coordinates, outline_color)
	var rect := Rect2(grid_origin + (size * cell_coordinates), size)
	draw_rect(rect, color, true)


func draw_isometric_grid(
		grid_origin: Vector2,
		cell_size: Vector2,
		grid_size: Vector2,
		width: float,
		color := Color.white
	) -> void:
	var outer_rect := Rect2(grid_origin, cell_size * grid_size)
	draw_rect(outer_rect, color, false, width)
	for cell in grid_size.x:
		var rect_x := Rect2(grid_origin.x + (cell_size.x * cell), grid_origin.y, cell_size.x, cell_size.y)
		draw_line(rect_x.position, rect_x.end, color, width)
		draw_line(Vector2(rect_x.end.x, rect_x.position.y), Vector2(rect_x.position.x, rect_x.end.y), color, width)
		for cell in grid_size.y:
			var rect_y := Rect2(rect_x.position.x, rect_x.position.y + (cell_size.y * cell), cell_size.x, cell_size.y)
			draw_line(rect_y.position, rect_y.end, color, width)
			draw_line(Vector2(rect_y.end.x, rect_y.position.y), Vector2(rect_y.position.x, rect_y.end.y), color, width)


func draw_isometric_cell(
		grid_origin: Vector2,
		cell_size: Vector2,
		cell_coordinates: Vector2,
		color := Color.white,
		use_outline := false,
		outline_width := 0.0,
		outline_color := Color.white
	) -> void:
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
		var offset = cell_coordinates * cell_size
		point += offset
		point.x += cell_size.x * 0.5
		points.append(point)

	if use_outline:
		_draw_isometric_cell_outline(grid_origin, cell_size, cell_coordinates, outline_color, outline_width)
	draw_polygon(points, colors)


# Method to workaround the cell outline drawing, it adds an extra offset based on the `outline_width`
func _draw_isometric_cell_outline(
		grid_origin: Vector2,
		cell_size: Vector2,
		cell: Vector2,
		color := Color.white,
		outline_width := 4.0
	) -> void:
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

	draw_polygon(points, colors)
