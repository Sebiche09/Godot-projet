extends Node2D

@onready var ambiance_jour = $ambiance1
@onready var tile_map = $TileMap
@onready var camera_personnage = $CharacterBody2D/Camera2D
@onready var camera_map = $TileMap/tilemap_cam
#----------------------------------- variable --------------------------------------------
@export var noise_image : NoiseTexture2D
@export var cave_text : NoiseTexture2D
@export var bedrock : int = 100
var grid_height = 300
var grid_width = 1000
var data_grid = []
#------------------------------------------------------------------------------------------

func _ready():	
	#initialisation de la grille
	for y in range (grid_height):
		data_grid.append([])
		for x in range(grid_width):
			data_grid[y].append("vide")  # Initialiser chaque cellule à "vide"
			
	var cave_noise : FastNoiseLite = cave_text.noise
	cave_noise.seed = randi()
	var noise : FastNoiseLite = noise_image.noise
	noise.seed = randi()
	var dirt_height = randi_range(7,8)
	var stone_height = grid_height-dirt_height+1
	const SPAWN_FLOWER_RATE = 10
	
	for x in range(grid_width):
		var noise_height = int((noise.get_noise_1d(x) * 0.5 + 0.5) * 60)
		for y in range(grid_height):
			if cave_noise.get_noise_2d(x,y) >0.45:
				data_grid[y][x] = "vide"
			elif y == noise_height-1 and randi() % SPAWN_FLOWER_RATE == 0:
				data_grid[y][x] = "fleur"
			elif y == noise_height:
				data_grid[y][x] = "herbe"
			elif y > noise_height and y <= noise_height + dirt_height:
				data_grid[y][x] = "terre"
			elif y > noise_height + dirt_height and y <= noise_height + dirt_height + stone_height:
				data_grid[y][x] = "pierre"			
			else:
				pass  # Laisser comme "vide" ou définir un autre type de tuile
	
	for y in range(grid_height):
		for x in range(grid_width):
			var tile_type = data_grid[y][x]
			var tile_id
			match tile_type:
				"terre":
					tile_id = 0
				"pierre":
					tile_id = 1
				"herbe":
					tile_id = 2
				"fleur":
					tile_id = 3
				"bedrock":	
					tile_id = 4
			if tile_id != null:
				BetterTerrain.set_cell(tile_map,0,Vector2i(x,y),tile_id)
	BetterTerrain.update_terrain_area(tile_map, 0,Rect2i(0,0, grid_width, grid_height))


func _input(event):
#------------------------------------------ MINAGE ----------------------------------------------------------
	if Input.is_action_pressed("chop"):
		var mouse_pos = get_global_mouse_position()
		var tile_pos = tile_map.local_to_map(mouse_pos)
		var index = BetterTerrain.get_cell(tile_map,0,tile_pos)
		if index != -1:
			tile_map.erase_cell(0, tile_pos)
			BetterTerrain.update_terrain_area(tile_map,
			0,Rect2i((tile_pos[0]-2),(tile_pos[1]-2),3,3),true)
			if BetterTerrain.get_cell(tile_map,0,Vector2i(tile_pos[0],tile_pos[1]+1)) != -1 :
				var tile_meta = BetterTerrain._get_tile_meta(tile_map.get_cell_tile_data(0, Vector2i(tile_pos[0],tile_pos[1]+1))).type
#-------------------------------------------------------------------------------------------------------------


	if event.is_action_pressed("caméra"):
		# Basculer entre les caméras
		if camera_personnage.enabled:
			camera_personnage.enabled = false
			camera_map.enabled = true
		else:
			camera_personnage.enabled = true
			camera_map.enabled = false
