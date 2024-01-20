extends Node2D

@export var noise_image : NoiseTexture2D
@onready var tile_map = $TileMap

var width: int = 1000
var dirt_height : int = 7
var stone_height : int = 100
var bedrock : int = 50

var height_tile_arr = []
var dirt_fill_arr = []
var flower_fill_arr = []
var stone_fill_arr = []
var bedrock_fill_arr = []
var proba = 0
func _ready():
	#crée une variable noise 
	var noise : FastNoiseLite = noise_image.noise

	for x in width:
		var noise_height = int(noise.get_noise_1d(x) * 20)
		dirt_height = randi_range(7,8)
		
			
		#Remplir de grass
		for y in dirt_height:
			if y == 0:
				proba = randi_range(0,20)
				if proba == 0:
					flower_fill_arr.append(Vector2(x, noise_height+y))
			else:
				dirt_fill_arr.append(Vector2(x, noise_height+y))

		BetterTerrain.set_cell(tile_map,0, Vector2(x, noise_height), 0)
		
		#Remplir de stone
		for y in range(dirt_height, stone_height): 
			if (noise_height+y) <= bedrock:
				stone_fill_arr.append(Vector2(x, noise_height+y))
			elif (noise_height+y) == bedrock:
					bedrock_fill_arr.append(Vector2(x, noise_height+y))
					
					
		BetterTerrain.set_cell(tile_map,0, Vector2(x, noise_height), 0)
	


	#Remplir la hauteur
	BetterTerrain.set_cells(tile_map,0, height_tile_arr, 0)
	BetterTerrain.update_terrain_cells(tile_map, 0, height_tile_arr,true)
	
	#Remplir de terre
	BetterTerrain.set_cells(tile_map,0, dirt_fill_arr, 0)
	BetterTerrain.update_terrain_cells(tile_map, 0, dirt_fill_arr,true)
	
	#Remplir de fleur
	BetterTerrain.set_cells(tile_map,0, flower_fill_arr, 3)
	BetterTerrain.update_terrain_cells(tile_map, 0, flower_fill_arr,true)

	#Remplir de stone
	BetterTerrain.set_cells(tile_map,0, stone_fill_arr, 1)
	BetterTerrain.update_terrain_cells(tile_map, 0, stone_fill_arr,true)
	
	#Remplir de bedrock
	BetterTerrain.set_cells(tile_map,0, bedrock_fill_arr, 2)
	BetterTerrain.update_terrain_cells(tile_map, 0, bedrock_fill_arr,true)
