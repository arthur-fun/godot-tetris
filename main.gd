extends Node2D

const brk_col_offset = 3
const score_per_brick = 10
const score_per_one_line = 100
const score_per_two_lines = 400
const score_per_three_lines = 900
const score_per_four_lines = 1600

var bricks = [
	[
		[[1,0,1],[1,1,1],[1,2,1],[1,3,1]],
		[[0,1,1],[1,1,1],[2,1,1],[3,1,1]]
	],
	[
		[[0,0,1],[0,1,1],[0,2,1],[1,2,1]],
		[[0,1,1],[1,1,1],[2,1,1],[2,0,1]],
		[[0,0,1],[1,0,1],[1,1,1],[1,2,1]],
		[[0,0,1],[0,1,1],[1,0,1],[2,0,1]]
	],
	[
		[[0,0,1],[0,1,1],[0,2,1],[1,1,1]],
		[[0,1,1],[1,0,1],[1,1,1],[2,1,1]],
		[[0,1,1],[1,0,1],[1,1,1],[1,2,1]],
		[[0,1,1],[1,1,1],[1,2,1],[2,1,1]]
	],
	[
		[[0,0,1],[0,1,1],[0,2,1],[1,0,1]],
		[[0,0,1],[0,1,1],[1,1,1],[2,1,1]],
		[[0,2,1],[1,0,1],[1,1,1],[1,2,1]],
		[[0,0,1],[1,0,1],[2,0,1],[2,1,1]]
	],
	[
		[[0,0,1],[0,1,1],[1,1,1],[1,2,1]],
		[[0,1,1],[1,0,1],[1,1,1],[2,0,1]]
	],
	[
		[[1,0,1],[1,1,1],[0,1,1],[0,2,1]],
		[[0,1,1],[1,1,1],[1,2,1],[2,2,1]]
	]
]
var bricks_0 = [
	[[1,0,1],[1,1,1],[1,2,1],[1,3,1]],
	[[0,0,1],[0,1,1],[0,2,1],[1,2,1]],
	[[0,0,1],[0,1,1],[0,2,1],[1,1,1]],
	[[0,0,1],[0,1,1],[0,2,1],[1,0,1]],
	[[0,0,1],[0,1,1],[1,1,1],[1,2,1]],
	[[1,0,1],[1,1,1],[0,1,1],[0,2,1]]
]
var current_index = 0
var current_one = [[0,0,0],[0,0,0],[0,0,0],[0,0,0]]
var next_index = 0
var next_one = [[0,0,0],[0,0,0],[0,0,0],[0,0,0]]
var brick_shape_index = 0
var started = false
var score_points = 0
var score_lines = 0

func _ready():
	randomize()
	assign_next_brick_to(next_one)
	$NextBrick.clear()
	$NextBrick.add_brick(next_one)
	$NextBrick.update()
	

func _unhandled_input(event):
	if event.is_action_pressed("move_left"):
		$TickTimer.stop()
		$Board.move_brick_left()
		$Board.update()
		$TickTimer.start()
	if event.is_action_pressed("move_right"):
		$TickTimer.stop()
		$Board.move_brick_right()
		$Board.update()
		$TickTimer.start()
	if event.is_action_pressed("move_down"):
		$TickTimer.stop()
		$Board.move_brick_down()
		$Board.update()
		$TickTimer.start()
	if event.is_action_pressed("move_to_bottom"):
		$TickTimer.stop()
		var full_line_cnt = $Board.move_brick_down()
		while full_line_cnt == 0:
			full_line_cnt = $Board.move_brick_down()
		post_move_down(full_line_cnt)
		$TickTimer.start()
	if event.is_action_pressed("change_shape"):
		$TickTimer.stop()
		brick_shape_index = (brick_shape_index+1) % len(bricks[current_index])
		var new_brick = bricks[current_index][brick_shape_index]
		copy_brick(new_brick, current_one)
		$Board.replace_brick(current_one)
		$Board.update()
		$TickTimer.start()



func copy_brick(from, to):
	for i in range(len(from)):
		var line = from[i]
		for j in range(len(line)):
			to[i][j]=from[i][j]


func assign_next_brick_to(target):
	next_index = randi() % len(bricks)
	print("Next index:", next_index)
	brick_shape_index = 0
	var next = bricks[next_index][brick_shape_index]
	print("Next brick:", next)
	copy_brick(next, target)	


func next_brick():
	copy_brick(next_one, current_one)
	for cell in current_one:
		cell[1] += brk_col_offset
	print("moved_brick", current_one)
	current_index = next_index
	$Board.add_brick(current_one)

	assign_next_brick_to(next_one)
	$NextBrick.clear()
	$NextBrick.add_brick(next_one)
	$NextBrick.update()


func _on_StartButton_pressed():
	if not started:
		$Board.clear_game_board()
		started = true
		if $TickTimer.is_stopped():
			next_brick()
			$TickTimer.start()
		else:
			$TickTimer.stop()


func post_move_down(full_line_cnt: int):
	if full_line_cnt != 0:
		if $Board.game_over():
			started = false
			print("Game Over")
			$TickTimer.stop()
			$Board.flash_game_over()
		else:
			if full_line_cnt > 0:
				if full_line_cnt == 1:
					score_lines += 1
					score_points += score_per_one_line
				elif full_line_cnt == 2:
					score_lines += 2
					score_points += score_per_two_lines
				elif full_line_cnt == 3:
					score_lines += 3
					score_points += score_per_three_lines
				elif full_line_cnt == 4:
					score_lines += 4
					score_points += score_per_four_lines
			elif full_line_cnt < 0:
				score_points += score_per_brick
				
			print("next brick")
			next_brick()
	$Board.update()
	$PointData.text = str(score_points)
	$PointData.update()
	$CleanData.text = str(score_lines)
	$CleanData.update()


func _on_TickTimer_timeout():
	$TickTimer.stop()
	print("TickTimer_timeout")
	print("next_one", next_one)
	var full_line_cnt = $Board.move_brick_down()
	post_move_down(full_line_cnt)
	$TickTimer.start()
	
