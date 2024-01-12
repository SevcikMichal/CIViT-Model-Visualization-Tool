extends Node2D

const stateFileLocation = "user://state.dat"

var font = load("res://fonts/Trueno-wml2.otf")
var mousePos: Vector2
var iterSizeX: int
var iterSizeY: int
var xLabels = ["Release", "Months", "Weeks", "Days", "Hours", "Minutes"]
var yLabels = ["Component", "Subsystem", "Partial Product", "Full Product", "Release", "Customer", "Post Deployment"]
var coverageLabels = [["L", "E"],["F", "N"]]
var help = true

var state: Array = []

var stateToColor = {
	CIViTNodeState.Best: Color.GREEN,
	CIViTNodeState.Good: Color.LIGHT_GREEN,
	CIViTNodeState.Poor: Color.YELLOW,
	CIViTNodeState.Bad: Color.ORANGE,
	CIViTNodeState.Worst: Color.RED,
	CIViTNodeState.None: Color.TRANSPARENT
}

enum CIViTNodeState { None, Best, Good, Poor, Bad, Worst }

class CIViTNode extends Object:
	var F: CIViTNodeState
	var N: CIViTNodeState
	var L: CIViTNodeState
	var E: CIViTNodeState
	var Automation: CIViTNodeState
	var Updated: bool
	
	func to_dictionary():
		return {
			"F": F,
			"N": N,
			"L": L,
			"E": E,
			"Automation": Automation,
			"Updated": Updated
		}

	static func from_dictionary(dict: Dictionary) -> CIViTNode:
		var node = CIViTNode.new()
		if dict.has("F"):
			node.F = dict["F"]
		if dict.has("N"):
			node.N = dict["N"]
		if dict.has("L"):
			node.L = dict["L"]
		if dict.has("E"):
			node.E = dict["E"]
		if dict.has("Automation"):
			node.Automation = dict["Automation"]
		if dict.has("Updated"):
			node.Updated = dict["Updated"]
		return node

func _ready():
	Engine.set_max_fps(120)
	if FileAccess.file_exists(stateFileLocation):
		var stateBytes = FileAccess.get_file_as_bytes(stateFileLocation)
		var serializedState = bytes_to_var_with_objects(stateBytes)
		for i in len(yLabels):
			var row = []
			for j in len(xLabels):
				row.append(CIViTNode.from_dictionary(serializedState[i][j]))
			state.append(row)
	else:
		for i in len(yLabels):
			var row = []
			for j in len(xLabels):
				row.append(CIViTNode.new())
			state.append(row)

# Currently absolutely not scalable and require full screen
func _draw():
	var viewportRect = get_viewport_rect()
	
	var title = "CIViT"
	
	# Set style for the box
	var style_box = StyleBoxFlat.new()
	style_box.set_border_color(Color.BLACK)
	style_box.set_bg_color(Color.TRANSPARENT)
	style_box.set_corner_radius_all(20)
	style_box.set_border_width_all(10)
	
	# Fill background with white color
	draw_rect(viewportRect, Color.WHITE)
	var x = viewportRect.size.x
	var y = viewportRect.size.y
	var xOffset = 500
	var yOffset = 150
	
	# Draw axes
	draw_line(Vector2(xOffset, y - yOffset), Vector2(x - xOffset, y - yOffset), Color.BLACK, 10.0)
	draw_line(Vector2(xOffset, y - yOffset + 5), Vector2(xOffset, yOffset), Color.BLACK, 10.0)	
	
	# Draw X labels
	iterSizeX = int((x - xOffset - xOffset ) / 6)
	var iterator = 0
	for n in range(xOffset + 100, x-xOffset - 100, iterSizeX):
		draw_string(font, Vector2(n, y - yOffset + 50), xLabels[iterator], HORIZONTAL_ALIGNMENT_CENTER, 180, 42, Color.BLACK)
		iterator += 1
	
	# Draw Y labels
	iterSizeY = int((y - yOffset - yOffset) / 7)
	iterator = 6
	for n in range(yOffset + 100, y-yOffset - 100, iterSizeY):
		draw_string(font, Vector2(xOffset - 400, n), yLabels[iterator], HORIZONTAL_ALIGNMENT_LEFT, -1, 42, Color.BLACK)
		iterator -= 1
		
	# Draw usage help
	if help:
		draw_string(font, Vector2(x - xOffset + 10, 100), "L. Click - Coverage level", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color.BLACK)
		draw_string(font, Vector2(x - xOffset + 10, 150), "Shift + L. Click - Automation level", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color.BLACK)
		draw_string(font, Vector2(x - xOffset + 10, 200), "CTRL/CMD + L. Click - Remove node", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color.BLACK)
		draw_string(font, Vector2(x - xOffset + 10, 250), "S - Saves visualization", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color.BLACK)
		draw_string(font, Vector2(x - xOffset + 10, 300), "E - Exports visualization to PNG", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color.BLACK)
		draw_string(font, Vector2(x - xOffset + 10, 400), "H - Toggle Help", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color.BLACK)
		draw_string(font, Vector2(x - xOffset + 10, 450), "Q - Exit the app", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color.BLACK)

	# Draw legend
	draw_rect(Rect2(x - xOffset + 200, y - yOffset - 50, 50, 50), Color.RED)
	draw_string(font, Vector2(x - xOffset + 200 + 80, y - yOffset - 10), "Worst", HORIZONTAL_ALIGNMENT_LEFT, -1, 42, Color.BLACK)
	draw_rect(Rect2(x - xOffset + 200, y - yOffset - 100, 50, 50), Color.ORANGE)
	draw_rect(Rect2(x - xOffset + 200, y - yOffset - 150, 50, 50), Color.YELLOW)
	draw_rect(Rect2(x - xOffset + 200, y - yOffset - 200, 50, 50), Color.LIGHT_GREEN)
	draw_rect(Rect2(x - xOffset + 200, y - yOffset - 250, 50, 50), Color.GREEN)
	draw_string(font, Vector2(x - xOffset + 200 + 80, y - yOffset - 210), "Best", HORIZONTAL_ALIGNMENT_LEFT, -1, 42, Color.BLACK)
	
	# Draw current state
	for i in len(yLabels):
		for j in len(xLabels):
			if state[i][j].Updated:
				
				# Draw boxes for coverage
				style_box.set_bg_color(stateToColor[state[i][j].F])
				draw_style_box(style_box, Rect2(iterSizeX * (j+1) + 200 + 100 * 0, iterSizeY * (i+1) - 100 * 1, 100, 100))
				draw_string(font, Vector2(iterSizeX * (j+1) + 200 + 100 * 0 + 40, iterSizeY * (i+1) - 100 * 1 + 60), coverageLabels[1][0],HORIZONTAL_ALIGNMENT_CENTER, -1, 42, Color.BLACK)
				
				style_box.set_bg_color(stateToColor[state[i][j].N])
				draw_style_box(style_box, Rect2(iterSizeX * (j+1) + 200 + 100 * 1, iterSizeY * (i+1) - 100 * 1, 100, 100))
				draw_string(font, Vector2(iterSizeX * (j+1) + 200 + 100 * 1 + 40, iterSizeY * (i+1) - 100 * 1 + 60), coverageLabels[1][1],HORIZONTAL_ALIGNMENT_CENTER, -1, 42, Color.BLACK)	
				
				style_box.set_bg_color(stateToColor[state[i][j].L])
				draw_style_box(style_box, Rect2(iterSizeX * (j+1) + 200 + 100 * 0, iterSizeY * (i+1) - 100 * 0, 100, 100))
				draw_string(font, Vector2(iterSizeX * (j+1) + 200 + 100 * 0 + 40, iterSizeY * (i+1) - 100 * 0 + 60), coverageLabels[0][0],HORIZONTAL_ALIGNMENT_CENTER, -1, 42, Color.BLACK)
				
				style_box.set_bg_color(stateToColor[state[i][j].E])
				draw_style_box(style_box, Rect2(iterSizeX * (j+1) + 200 + 100 * 1, iterSizeY * (i+1) - 100 * 0, 100, 100))
				draw_string(font, Vector2(iterSizeX * (j+1) + 200 + 100 * 1 + 40, iterSizeY * (i+1) - 100 * 0 + 60), coverageLabels[0][1],HORIZONTAL_ALIGNMENT_CENTER, -1, 42, Color.BLACK)
				
				style_box.set_bg_color(Color.TRANSPARENT)				
				# Draw box for automation
				var borderColor = stateToColor[state[i][j].Automation]
				borderColor = Color.BLACK if borderColor == Color.TRANSPARENT else borderColor
				style_box.set_border_color(borderColor)
				style_box.set_border_width_all(15)
				draw_style_box(style_box, Rect2(iterSizeX * (j+1) + 200, iterSizeY*(i+1) - 100, 200, 200))
				style_box.set_border_color(Color.BLACK)
				style_box.set_border_width_all(10)
				
	var gridMousePosX := int(mousePos.x + 100)
	var gridMousePosY := int(mousePos.y + 100)

	if gridMousePosX % iterSizeX < 100 || gridMousePosX % iterSizeX > 300 && gridMousePosX % iterSizeX < 400:
		if gridMousePosY % iterSizeY < 200:
			
			# Calculate indexes inside the grid
			var xIndex = floor(mousePos.x / iterSizeX)
			var yIndex = ceil(gridMousePosY / iterSizeY)
			
			# Check if we are on valid position
			if xIndex >= 1 && xIndex <= 6 && yIndex >= 1 && yIndex <= 7 && !state[yIndex - 1][xIndex - 1].Updated:
				# Set the Y/X label combination as title
				title = yLabels[len(yLabels) - yIndex] + "/" + xLabels[xIndex - 1]
				
				var startX = iterSizeX * xIndex + 200
				var startY = iterSizeY* yIndex - 100
				
				# Calculate indexes within the rectangle
				var xIndexInRect = (int(mousePos.x - startX) % 200) / 100
				var yIndexInRect = (int(mousePos.y - startY) % 200) / 100
				# Swap y because of indexing
				yIndexInRect = 0 if yIndexInRect == 1 else 1
				
				# Draw boxes for coverage
				draw_style_box(style_box, Rect2(startX + 100 * xIndexInRect, iterSizeY * yIndex - 100 * yIndexInRect, 100, 100))
				draw_string(font, Vector2(startX + 100 * xIndexInRect + 40, iterSizeY * yIndex - 100 * yIndexInRect + 60), coverageLabels[yIndexInRect][xIndexInRect],HORIZONTAL_ALIGNMENT_CENTER, -1, 42, Color.BLACK)
				
				# Draw box for automation
				draw_style_box(style_box, Rect2(startX, startY, 200, 200))
	
	#Draw Title
	draw_string(font, Vector2(10, 50), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 42, Color.BLACK)

func _process(delta):
	# Get current mouse position on every frame
	mousePos = get_viewport().get_mouse_position()
	queue_redraw()

func _input(event):
	# On pressed "S" the state is saved to a file
	if event is InputEventKey:
		if event.keycode == KEY_S and event.is_pressed():
			serializeState()
			return
		if event.keycode == KEY_Q and event.is_pressed():
			if OS.get_name() != "Web":
				get_tree().quit()
			return
		if event.keycode == KEY_H and event.is_pressed():
			help = !help
			return
		if event.keycode == KEY_E  and event.is_pressed():
			exportToPng()
			return
		
	# On click update the state of visualization
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			var gridMousePosY := int(mousePos.y + 100)
			var xIndex = floor(mousePos.x / iterSizeX) - 1
			var yIndex = ceil(gridMousePosY / iterSizeY) - 1
			
			# Check if click is inside one of the nodes
			if xIndex >= 0 && xIndex < 6 && yIndex >= 0 && yIndex < 7:
				# Holding command/ctrl will remove the node
				if event.is_command_or_control_pressed():
					state[yIndex][xIndex] = CIViTNode.new()
					return
					
				state[yIndex][xIndex].Updated = true
				
				# Holding shift update automation
				if event.shift_pressed:
					state[yIndex][xIndex].Automation = (state[yIndex][xIndex].Automation + 1) % 6
					return
				
				# Calculate indexes within the rectangle
				var startX = iterSizeX * (xIndex + 1) + 200
				var startY = iterSizeY * (yIndex + 1) - 100
				
				# Calculate indexes within the rectangle
				var xIndexInRect = (int(mousePos.x - startX) % 200) / 100
				var yIndexInRect = (int(mousePos.y - startY) % 200) / 100
				# Swap y because of indexing
				yIndexInRect = 0 if yIndexInRect == 1 else 1
				
				# Update selected coverage
				if xIndexInRect == 0 && yIndexInRect == 0:
					state[yIndex][xIndex].L = (state[yIndex][xIndex].L + 1) % 6
				if xIndexInRect == 0 && yIndexInRect == 1:
					state[yIndex][xIndex].F = (state[yIndex][xIndex].F + 1) % 6
				if xIndexInRect == 1 && yIndexInRect == 0:
					state[yIndex][xIndex].E = (state[yIndex][xIndex].E + 1) % 6
				if xIndexInRect == 1 && yIndexInRect == 1:
					state[yIndex][xIndex].N = (state[yIndex][xIndex].N + 1) % 6

func serializeState():
	var stateToSerialize = []
	
	for i in len(yLabels):
		var row = []
		for j in len(xLabels):
			row.append(state[i][j].to_dictionary())
		stateToSerialize.append(row)
	
	var stateBytes = var_to_bytes_with_objects(stateToSerialize)
	
	var file = FileAccess.open(stateFileLocation, FileAccess.WRITE)
	
	file.store_buffer(stateBytes)

	file.close()
	
func exportToPng():
	var image = get_viewport().get_texture().get_image()
	
	var time = Time.get_datetime_dict_from_system()

	if OS.get_name() == "Web":
		JavaScriptBridge.download_buffer(image.save_png_to_buffer(), "%04d_%02d_%02d_%02d%02d%02d_CIViT.png" % [time.year, time.month, time.day, time.hour, time.minute, time.second], "image/png")
	else:
		DirAccess.make_dir_absolute("./export")
		image.save_png("./export/%04d_%02d_%02d_%02d%02d%02d_CIViT.png" % [time.year, time.month, time.day, time.hour, time.minute, time.second])
