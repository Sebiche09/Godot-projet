extends Node2D

@onready var ambiance_jour = $ambiance1
@onready var tile_map = $TileMap

#----------------------------------- variable --------------------------------------------
@export var noise_image : NoiseTexture2D
@export var cave_text : NoiseTexture2D
@export var width: int = 500
@export var dirt_height : int = 7
@export var stone_height : int = 100
@export var bedrock : int = 100

var grass_fill_arr = []
var grass_fill_dict = {}
var dirt_fill_arr = []
var flower_fill_arr = []
var stone_fill_arr = []
var bedrock_fill_arr = []
var tile_arr = []
var proba = 0
#------------------------------------------------------------------------------------------
func _on_Timer_timeout():
	pass
func _ready():
	
	AudioStreamRandomizer.PLAYBACK_RANDOM
	#crée une variable noise qui contient la noisemap 
	var noise : FastNoiseLite = noise_image.noise
	#génère une seed aléatoire pour la noisemap
	noise.seed = randi()
	var cave_noise : FastNoiseLite = cave_text.noise
	cave_noise.seed = randi()
	var noise_height
	
	#prend chaque valeur de x pour toute la longueur de la map
	for x in width:
		#défini un valeur comprise entre (x et x+...) pour crée la premiere couche
		noise_height = int(noise.get_noise_1d(x) * 20)

		#défini un nombre random entre 7 et 8 qui permettra d'avoir plus ou moins de couche de dirt
		dirt_height = randi_range(7,8)


		
		#On parcours pour x (horizontale) les y
		for y in range(-1,dirt_height):
			if cave_noise.get_noise_2d(x,y) >-0.75:
				if y == -1:
					proba = randi_range(0,20)
					if proba == 0:
						flower_fill_arr.append(Vector2(x, noise_height+y))
				elif y == 0:
					grass_fill_arr.append(Vector2(x, noise_height))
				else:
					dirt_fill_arr.append(Vector2(x, noise_height+y))
					
		#Remplir de stone
		for y in range(dirt_height, stone_height): 
			if (noise_height+y) <= bedrock:
				if cave_noise.get_noise_2d(x,y) >-0.75:
					stone_fill_arr.append(Vector2(x, noise_height+y))
			elif (noise_height+y) == bedrock:
					bedrock_fill_arr.append(Vector2(x, noise_height+y))



	#Remplir de fleur
	BetterTerrain.set_cells(tile_map,0, flower_fill_arr, 3)
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
	
	BetterTerrain.set_cells(tile_map,0, grass_fill_arr, 2)
	for vec in grass_fill_arr:
		var i = vec.x-1
		var j = vec.y-1
		BetterTerrain.update_terrain_area(tile_map,0,Rect2i(Vector2i(i,j), Vector2i(3,3)),true)

func _process(delta):
	if grass_fill_dict.size() > 0:
		for cle in grass_fill_dict:
			grass_fill_dict[cle] += randi_range(1,5)
			if grass_fill_dict[cle] > 10000:
				BetterTerrain.set_cell(tile_map, 0, cle, 2)
				grass_fill_dict.erase(cle) # Retirer la clé une fois mise à jour

	
func _input(event):
	if Input.is_action_pressed("chop"):
		var mouse_pos = get_global_mouse_position()
		var tile_pos = tile_map.local_to_map(mouse_pos)
		var index = BetterTerrain.get_cell(tile_map,0,tile_pos)
		if grass_fill_dict.size() > 0:
			for cle in grass_fill_dict:
				if tile_pos == cle:
					grass_fill_dict.erase(cle)
		if index != -1:
				tile_map.erase_cell(0, tile_pos)
				BetterTerrain.update_terrain_area(tile_map,
				0,Rect2i((tile_pos[0]-2),(tile_pos[1]-2),3,3),true)
				if BetterTerrain.get_cell(tile_map,0,Vector2i(tile_pos[0],tile_pos[1]+1)) != -1:
					grass_fill_dict[Vector2i(tile_pos[0],tile_pos[1]+1)] = 0
				
	if Input.is_action_pressed("Build"):
		var mouse_pos = get_global_mouse_position()
		var tile_pos = tile_map.local_to_map(mouse_pos)
		if BetterTerrain.get_cell(tile_map,0,tile_pos) == -1:
			BetterTerrain.set_cell(tile_map,0, tile_pos, 0)
			BetterTerrain.update_terrain_area(tile_map,
				0,Rect2i((tile_pos[0]-2),(tile_pos[1]-2),3,3),true)
				

