extends Node2D

@export var noise_image : NoiseTexture2D
@onready var tile_map = $TileMap

#----------------------------------- variable --------------------------------------------
var width: int = 1000
var dirt_height : int = 7
var stone_height : int = 100
var bedrock : int = 50

var grass_fill_arr = []
var dirt_fill_arr = []
var flower_fill_arr = []
var stone_fill_arr = []
var bedrock_fill_arr = []
var proba = 0
#------------------------------------------------------------------------------------------


func _ready():

	#crée une variable noise qui contient la noisemap 
	var noise : FastNoiseLite = noise_image.noise

	#génère une seed aléatoire pour la noisemap
	noise.seed = randi()

	#prend chaque valeur de x pour toute la longueur de la map
	for x in width:

		#défini un valeur comprise entre (x et x+...) pour crée la premiere couche
		var noise_height = int(noise.get_noise_1d(x) * 20)

		#défini un nombre random entre 7 et 8 qui permettra d'avoir plus ou moins de couche de dirt
		dirt_height = randi_range(7,8)



		#On parcours pour x (horizontale) les y
		for y in range(0,dirt_height):
			if y == 0:
				grass_fill_arr.append(Vector2(x, noise_height+y))
				proba = randi_range(0,20)
				if proba == 0:
					flower_fill_arr.append(Vector2(x, noise_height-1))
			elif y == 1 or y == 2:
				grass_fill_arr.append(Vector2(x, noise_height+y))
			else :
				dirt_fill_arr.append(Vector2(x, noise_height+y))

		BetterTerrain.set_cell(tile_map,0, Vector2(x, noise_height), 0)

		#Remplir de stone
		for y in range(dirt_height, stone_height): 
			if (noise_height+y) <= bedrock:
				stone_fill_arr.append(Vector2(x, noise_height+y))
			elif (noise_height+y) == bedrock:
					bedrock_fill_arr.append(Vector2(x, noise_height+y))



	#Remplir de fleur
	BetterTerrain.set_cells(tile_map,0, flower_fill_arr, 3)
	BetterTerrain.update_terrain_cells(tile_map, 0, flower_fill_arr,true)

	#Remplir de grass
	BetterTerrain.set_cells(tile_map,0, flower_fill_arr, 2)
	BetterTerrain.update_terrain_cells(tile_map, 0, flower_fill_arr,true)

	#Remplir de terre
	BetterTerrain.set_cells(tile_map,0, dirt_fill_arr, 0)
	BetterTerrain.update_terrain_cells(tile_map, 0, dirt_fill_arr,true)

	#Remplir de stone
	BetterTerrain.set_cells(tile_map,0, stone_fill_arr, 1)
	BetterTerrain.update_terrain_cells(tile_map, 0, stone_fill_arr,true)

	#Remplir de bedrock
	BetterTerrain.set_cells(tile_map,0, bedrock_fill_arr, 4)
	BetterTerrain.update_terrain_cells(tile_map, 0, bedrock_fill_arr,true)
