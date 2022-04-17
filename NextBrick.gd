extends Node2D

const board_border_width = 3
const brk_padding = 1
const brk_border_width = 2
const brk_margin = 2
const num_brk_per_line = 4

var brk_size: Vector2
var brk_border_size: Vector2
var brk_inner_size: Vector2

var game_board = [
	[0, 0, 0, 0],
	[0, 0, 0, 0]
]

export var board_pos: Vector2 = Vector2(0, 0)
export var board_size: Vector2 = Vector2(86, 46)


func clear():
	game_board = [[0, 0, 0, 0],	[0, 0, 0, 0]]

func add_brick(item) -> bool:
	for p in item:
		game_board[p[0]][p[1]] += p[2]
	return false


func remove_brick(item) -> bool:
	for p in item:
		game_board[p[0]][p[1]] -= p[2]
		if game_board[p[0]][p[1]] < 0:
			return false
	return true


# Called when the node enters the scene tree for the first time.
func _ready():
	print("board_pos", board_pos)
	print("board_size", board_size)
	
	var brk_len = (board_size.x-2*board_border_width)/num_brk_per_line
	brk_size = Vector2(brk_len, brk_len)
	print("brick_size", brk_size)

	var brk_border_len = brk_len-2*brk_margin
	brk_border_size = Vector2(brk_border_len, brk_border_len)
	print("brick_border_size", brk_border_size)

	var brk_inner_len = brk_border_len-2*(brk_border_width+brk_padding)
	brk_inner_size = Vector2(brk_inner_len, brk_inner_len)
	print("brick_inner_size", brk_inner_size)
	
	update()


func _draw():
	draw_rect(Rect2(board_pos, board_size), Color.honeydew, true)
	paint_background()

func paint_background():
	for i in range(4):
		for j in range(2):
			var border_x = board_pos.x + board_border_width+brk_size.x*i+brk_margin
			var border_y = board_pos.y + board_border_width+brk_size.y*j+brk_margin
			var border_pos = Vector2(border_x, border_y)
			var inner_pos = Vector2(border_x+brk_border_width+brk_padding, border_y+brk_border_width+brk_padding)
			var color = Color(0, 0, 0, 0.2) if game_board[j][i] == 0 else Color(0, 0, 0, 0.8)
			paint_brick(border_pos, brk_border_size, inner_pos, brk_inner_size, color)

func paint_brick(pos: Vector2, size: Vector2, inner_pos: Vector2, inner_size: Vector2, color: Color):
	draw_rect(Rect2(pos, size), color, false, brk_border_width)
	draw_rect(Rect2(inner_pos, inner_size), color, true)
