extends Node2D

@onready var ambiance_jour = $ambiance1
@onready var tile_map = $TileMap
@onready var camera_personnage = $CharacterBody2D/Camera2D
@onready var camera_map = $TileMap/tilemap_cam
@onready var character = $CharacterBody2D
@onready var label_pos = $CharacterBody2D/gui/HBoxContainer/Label
@onready var label_infos =$CharacterBody2D/chargement/boxInfos/Label
@onready var label_chargement =$CharacterBody2D/chargement/boxChargement/Label
@onready var screen_chargement =$CharacterBody2D/chargement/ColorRect
#----------------------------------- variable --------------------------------------------
@export var noise_image : NoiseTexture2D
@export var cave_text : NoiseTexture2D
@export var bedrock : int = 100
var map_height = 100
var map_width = 300

var data_dict = {}
var herbe_arr = []
var background_dict = {}
var changeset : Dictionary
var changeset_background : Dictionary
var is_map_ready = false

func chop_tree(index,tile_pos) -> void:
	#-------------------------------------- COUPER DU BOIS ------------------------------------------------------
	if index == 7 or index == 8:	
		var y_offset = 0 # Commencez à l'offset 0 (le bloc courant)
		while true:
			var bloc_type = BetterTerrain.get_cell(tile_map, 0, Vector2i(tile_pos[0], tile_pos[1] - y_offset))
			if bloc_type == 7 or bloc_type == 8:
				tile_map.erase_cell(0, Vector2i(tile_pos[0], tile_pos[1] - y_offset))
				if BetterTerrain.get_cell(tile_map, 0, Vector2i(tile_pos[0]-1, tile_pos[1] - y_offset)) == 9 or BetterTerrain.get_cell(tile_map, 0, Vector2i(tile_pos[0]-1, tile_pos[1] - y_offset)) == 8:
					tile_map.erase_cell(0, Vector2i(tile_pos[0]-1, tile_pos[1] - y_offset))
				if BetterTerrain.get_cell(tile_map, 0, Vector2i(tile_pos[0]+1, tile_pos[1] - y_offset)) == 9 or BetterTerrain.get_cell(tile_map, 0, Vector2i(tile_pos[0]+1, tile_pos[1] - y_offset)) == 8:
					tile_map.erase_cell(0, Vector2i(tile_pos[0]+1, tile_pos[1] - y_offset))
				BetterTerrain.update_terrain_area(tile_map,
				0,Rect2i((tile_pos[0]-1),(tile_pos[1]-y_offset-1),3,3),true)
				y_offset += 1 # Augmentez l'offset pour le bloc au-dessus
			else:
				break
	#------------------------------------------------------------------------------------------------------------
func make_tree() -> void:
	const SPAWN_TREE_RATE = 3
	const SPAWN_STICK_RATE = 4
	var skip =4
	for i in range(herbe_arr.size() - 2):
		if skip > 0:
			skip -= 1 # Décrémenter le compteur de saut et continuer la boucle
			continue
		if herbe_arr[i].y == herbe_arr[i + 1].y and herbe_arr[i + 1].y == herbe_arr[i + 2].y:
			if randi() % SPAWN_TREE_RATE == 0:
				var tree_height = -1
				var is_ok = true
				match randi_range(0,2):
 #-------------------------------- CAS 1 : arbre 2 racines -----------------------------------------------------------------------
					0:
						data_dict[Vector2i(herbe_arr[i].x, herbe_arr[i].y - 1)] = 8
						for j in randi_range(8,10):
							if tree_height ==-1:
								data_dict[Vector2i(herbe_arr[i].x + 1, herbe_arr[i].y + tree_height)] = 7
							else:
								data_dict[Vector2i(herbe_arr[i].x + 1, herbe_arr[i].y + tree_height)] = 8
								if is_ok :
									if randi() % SPAWN_STICK_RATE == 0 and is_ok:
										match randi_range(0,2):
											0:
												data_dict[Vector2i(herbe_arr[i].x , herbe_arr[i].y + tree_height)] = 9
											1:
												data_dict[Vector2i(herbe_arr[i].x + 2, herbe_arr[i].y + tree_height)] = 9
											2:
												data_dict[Vector2i(herbe_arr[i].x, herbe_arr[i].y + tree_height)] = 9
												data_dict[Vector2i(herbe_arr[i].x + 2, herbe_arr[i].y + tree_height)] = 9
									is_ok = false
								else :
									is_ok = true								
							tree_height -=1
						data_dict[Vector2i(herbe_arr[i].x + 2, herbe_arr[i].y - 1)] = 8            
						skip = 4
 #------------------------------------------------------------------------------------------------------------------------------

 #-------------------------------- CAS 2 : arbre 1 racines à droite------------------------------------------------------------
					1:
						data_dict[Vector2i(herbe_arr[i].x, herbe_arr[i].y - 1)] = 8
						for j in randi_range(8,10):
							if tree_height ==-1:
								data_dict[Vector2i(herbe_arr[i].x + 1, herbe_arr[i].y + tree_height)] = 7
							else:
								data_dict[Vector2i(herbe_arr[i].x + 1, herbe_arr[i].y + tree_height)] = 8
								if randi() % SPAWN_STICK_RATE == 0 and is_ok:
									match randi_range(0,2):
										0:
											data_dict[Vector2i(herbe_arr[i].x , herbe_arr[i].y + tree_height)] = 9
										1:
											data_dict[Vector2i(herbe_arr[i].x + 2, herbe_arr[i].y + tree_height)] = 9
										2:
											data_dict[Vector2i(herbe_arr[i].x, herbe_arr[i].y + tree_height)] = 9
											data_dict[Vector2i(herbe_arr[i].x + 2, herbe_arr[i].y + tree_height)] = 9
									is_ok = false
								else :
									is_ok = true	
							tree_height -=1
						skip = 4
#------------------------------------------------------------------------------------------------------------------------------

#-------------------------------- CAS 3 : arbre 1 racines à gauche------------------------------------------------------------
					2:
						for j in randi_range(8,10):
							if tree_height ==-1:
								data_dict[Vector2i(herbe_arr[i].x , herbe_arr[i].y + tree_height)] = 7
							else:
								data_dict[Vector2i(herbe_arr[i].x, herbe_arr[i].y + tree_height)] = 8
								if randi() % SPAWN_STICK_RATE == 0 and is_ok:
									match randi_range(0,2):
										0:
											data_dict[Vector2i(herbe_arr[i].x-1 , herbe_arr[i].y + tree_height)] = 9
										1:
											data_dict[Vector2i(herbe_arr[i].x+1, herbe_arr[i].y + tree_height)] = 9
										2:
											data_dict[Vector2i(herbe_arr[i].x-1, herbe_arr[i].y + tree_height)] = 9
											data_dict[Vector2i(herbe_arr[i].x + 1, herbe_arr[i].y + tree_height)] = 9
									is_ok = false
								else :
									is_ok = true	
							tree_height -=1
						data_dict[Vector2i(herbe_arr[i].x+1, herbe_arr[i].y - 1)] = 8
						skip = 4
					
	#------------------------------------------------------------------------------------------

func make_map() -> void:
	var cave_noise : FastNoiseLite = cave_text.noise
	cave_noise.seed = randi()
	var noise : FastNoiseLite = noise_image.noise
	noise.seed = randi()
	var dirt_height = randi_range(7,8)
	var stone_height = map_height-dirt_height+1
	const SPAWN_FLOWER_RATE = 10
	
	for x in range(map_width):
		var noise_height = int((noise.get_noise_1d(x) * 0.5 + 0.5) * 60)
		for y in range(map_height):
			
			#fleurs
			if y == noise_height-1 and randi() % SPAWN_FLOWER_RATE == 0:
				data_dict[Vector2i(x,y)] = 3

			#herbes
			if y == noise_height:
				data_dict[Vector2i(x,y)] = 2
				if cave_noise.get_noise_2d(x,y) <0.635:
					herbe_arr.append(Vector2i(x,y))
			
			#terre
			if y > noise_height and y <= noise_height + dirt_height:
				data_dict[Vector2i(x,y)] = 0
				background_dict[Vector2i(x,y)] = 5
				
			#pierre
			if y > noise_height + dirt_height and y <= noise_height + dirt_height + stone_height:
				data_dict[Vector2i(x,y)] = 1
				background_dict[Vector2i(x,y)] = 6
				
			#cave
			if cave_noise.get_noise_2d(x,y) >0.635:
				data_dict[Vector2i(x,y)] = -1

	make_tree()
	
	label_infos.text = "Génération du terrain..."
	changeset = BetterTerrain.create_terrain_changeset(tile_map, 0, data_dict)
	changeset_background = BetterTerrain.create_terrain_changeset(tile_map, 1, background_dict)

func _ready() -> void:	
	character.set_physics_process(false)
	make_map()
	
func _input(event) -> void:
	#------------------------------------------ MINAGE ----------------------------------------------------------
	if Input.is_action_pressed("chop"):
		var mouse_pos = get_global_mouse_position()
		var tile_pos = tile_map.local_to_map(mouse_pos)
		var index = BetterTerrain.get_cell(tile_map,0,tile_pos)
	#------------------------------------------------------------------------------------------------------------	
		chop_tree(index,tile_pos)
	
		
	
	
	
		if index != -1:
			tile_map.erase_cell(0, tile_pos)
			BetterTerrain.update_terrain_area(tile_map,
			0,Rect2i((tile_pos[0]-1),(tile_pos[1]-1),3,3),true)
			if BetterTerrain.get_cell(tile_map,0,Vector2i(tile_pos[0],tile_pos[1]+1)) != -1 :
				var tile_meta = BetterTerrain._get_tile_meta(tile_map.get_cell_tile_data(0, Vector2i(tile_pos[0],tile_pos[1]+1))).type
				print(tile_meta)
	#-------------------------------------------------------------------------------------------------------------

	#------------------------------------------ CAMERA ----------------------------------------------------------
	if event.is_action_pressed("caméra"):
		# Basculer entre les caméras
		if camera_personnage.enabled:
			camera_personnage.enabled = false
			camera_map.enabled = true
		else:
			camera_personnage.enabled = true
			camera_map.enabled = false
	#-------------------------------------------------------------------------------------------------------------

func _process(delta:float) -> void:
	if BetterTerrain.is_terrain_changeset_ready(changeset):
		BetterTerrain.apply_terrain_changeset(changeset)
	if BetterTerrain.is_terrain_changeset_ready(changeset_background):
		BetterTerrain.apply_terrain_changeset(changeset_background)
		
		changeset = {}
		changeset_background = {}
		is_map_ready = true
		label_infos.text = ""
		label_chargement.text = ""
		screen_chargement.visible = false 
	if is_map_ready:
		character.set_physics_process(true)
	# A supposer que c'est dans une fonction _process ou _input
	var mouse_pos = get_global_mouse_position()  # Obtenez la position globale de la souris
	var tile_pos = tile_map.local_to_map(mouse_pos)
	var index = BetterTerrain.get_cell(tile_map,0,tile_pos)
	match index :
		-1:
			index = "vide"
		0:
			index  = "terre"
		1:
			index = "pierre"
		2:
			index = "herbe"
		3:
			index = "fleur"
	label_pos.text = str(tile_pos) + "|" + str(index)
