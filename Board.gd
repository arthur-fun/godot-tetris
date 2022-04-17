extends Node2D

const board_border_width = 3
const brk_padding = 1
const brk_border_width = 2
const brk_margin = 2
const num_brk_per_col = 10
const num_brk_per_row = 20
const last_board_line_index = 19

var brk_size: Vector2
var brk_border_size: Vector2
var brk_inner_size: Vector2

var game_board = [
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
]

var current = [
	[0,0,0],[0,0,0],[0,0,0],[0,0,0]
]

export var board_pos: Vector2 = Vector2(0, 0)
export var board_size: Vector2 = Vector2(206, 406)


func copy_brick(from, to):
	for i in range(len(from)):
		var line = from[i]
		for j in range(len(line)):
			to[i][j]=from[i][j]


func move_brick_left():
	print("move_brick_left")
	print("Before move", current)
	for cell in current:
		if cell[1] <= 0:
			return
		if game_board[cell[0]][cell[1]-1] > 1:
			return
	remove_brick(current)
	for cell in current:
		cell[1] -= 1
	print("After move", current)
	add_brick(current)


func move_brick_right():
	print("move_brick_right")
	print("Before move", current)
	for cell in current:
		if cell[1] >= num_brk_per_col - 1:
			return
		if game_board[cell[0]][cell[1]+1] > 1:
			return
	remove_brick(current)
	for cell in current:
		cell[1] += 1
	print("After move", current)
	add_brick(current)


func move_brick_down() -> int:
	print("move_brick_down", current)
	for cell in current:
		if cell[0] >= last_board_line_index:
			return -1
		if game_board[cell[0]+1][cell[1]] > 1:
			return -1
	remove_brick(current)
	for item in current:
		item[0] += 1
	var last_line = add_brick(current)

	var full_line_cnt = 0
	var full_lines = []
	if last_line > 0:
		for i in range(4):
			var total = 0
			for brick_val in game_board[last_line - i]:
				total += brick_val
			if total == 2*num_brk_per_col:
				full_line_cnt += 1
				full_lines.append(last_line - i)
	clean_line(full_lines)
	return full_line_cnt


func replace_brick(new_brick):
	var x_offset = num_brk_per_row
	var y_offset = num_brk_per_col
	for cell in current:
		if cell[0] <= x_offset:
			x_offset = cell[0]
		if cell[1] <= y_offset:
			y_offset = cell[1]
	for cell in new_brick:
		if cell[0]+x_offset >= num_brk_per_row:
			return
		if cell[1]+y_offset >= num_brk_per_col:
			return
		if game_board[cell[0]+x_offset][cell[1]+y_offset] > 1:
			return
	remove_brick(current)
	copy_brick(new_brick, current)
	for cell in current:
		cell[0] += x_offset
		cell[1] += y_offset
	add_brick(current)


func add_brick(item) -> int:
	copy_brick(item, current)
	var pinned = false
	var last_line_index = -1
	for p in current:
		game_board[p[0]][p[1]] += p[2]
		if p[0] >= last_board_line_index:
			pinned = true
		elif game_board[p[0]][p[1]] > 1:
			pinned = true
		elif game_board[p[0]+1][p[1]] > 1:
			pinned = true
	if pinned:
		for p in current:
			game_board[p[0]][p[1]] += p[2]
			if p[0] > last_line_index:
				last_line_index = p[0]
		
	return last_line_index
		

func remove_brick(item):
	for p in item:
		game_board[p[0]][p[1]] -= p[2]


func game_over() -> bool:
	for item in game_board[0]:
		if item > 1:
			return true
	return false


func clean_line(line_index_list):
	var num_cleaned_lines = len(line_index_list)
	var last_full_line_index = -1
	for idx in line_index_list:
		if idx > last_full_line_index:
			last_full_line_index = idx
		for cell in game_board[idx]:
			cell = 0
	var last_partial_line_index = last_full_line_index - num_cleaned_lines
	update()
	for li in range(last_partial_line_index+1):
		for col in range(num_brk_per_col):
			game_board[last_full_line_index-li][col] = game_board[last_partial_line_index-li][col]
	update()


func flash_game_over():
	$FlashTimer.start()
	for i in range(num_brk_per_row):
		var total_line_bricks = 0
		for j in range(num_brk_per_col):
			total_line_bricks += game_board[num_brk_per_row-1-i][j]
			game_board[num_brk_per_row-1-i][j] = 1
		if total_line_bricks == num_brk_per_col*2:
			continue
		update()
		yield($FlashTimer, "timeout")
	$FlashTimer.stop()
	clear_game_board()
	update()


func clear_game_board():
	for i in range(num_brk_per_row):
		for j in range(num_brk_per_col):
			game_board[i][j] = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	print("board_pos", board_pos)
	print("board_size", board_size)
	
	var brk_len = (board_size.x-2*board_border_width)/num_brk_per_col
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
	draw_rect(Rect2(board_pos, board_size), Color(0, 0, 0, 0.8), false, board_border_width)
	for i in range(num_brk_per_row):
		for j in range(num_brk_per_col):
			var border_x = board_pos.x + board_border_width+brk_size.x*j+brk_margin
			var border_y = board_pos.y + board_border_width+brk_size.y*i+brk_margin
			var border_pos = Vector2(border_x, border_y)
			var inner_pos = Vector2(border_x+brk_border_width+brk_padding, border_y+brk_border_width+brk_padding)
			var color = Color(0, 0, 0, 0.2) if game_board[i][j] == 0 else Color(0, 0, 0, 0.8)
			draw_rect(Rect2(border_pos, brk_border_size), color, false, brk_border_width)
			draw_rect(Rect2(inner_pos, brk_inner_size), color, true)


