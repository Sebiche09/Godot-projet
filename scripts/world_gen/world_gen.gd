extends Node2D

@export var noise_image : NoiseTexture2D
@onready var tile_map = $TileMap
var width: int = 1000
var dirt_height : int = 7
var stone_height : int = 100

var height_tile_arr = []
var dirt_fill_arr = []
var stone_fill_arr = []

func _ready():
	var noise : FastNoiseLite = noise_image.noise

	for x in width:
		var noise_height = int(noise.get_noise_1d(x) * 20)

		#Remplir de grass
		for y in dirt_height:
			dirt_fill_arr.append(Vector2(x, noise_height+y))

		BetterTerrain.set_cell(tile_map,0, Vector2(x, noise_height), 0)

		#Remplir de stone
		for y in range(dirt_height, stone_height): 
			stone_fill_arr.append(Vector2(x, noise_height+y))

		BetterTerrain.set_cell(tile_map,0, Vector2(x, noise_height), 0)



	#Remplir la hauteur
	BetterTerrain.set_cells(tile_map,0, height_tile_arr, 0)
	BetterTerrain.update_terrain_cells(tile_map, 0, height_tile_arr,true)

	#Remplir de terre
	BetterTerrain.set_cells(tile_map,0, dirt_fill_arr, 0)
	BetterTerrain.update_terrain_cells(tile_map, 0, dirt_fill_arr,true)

		#Remplir de stone
	BetterTerrain.set_cells(tile_map,0, stone_fill_arr, 1)
	BetterTerrain.update_terrain_cells(tile_map, 0, stone_fill_arr,true)
