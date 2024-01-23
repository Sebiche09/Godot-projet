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
@export var bedrock : int = 200
var map_height = 200
var map_width = 400
var data_dict = {}
var background_dict = {}
var changeset : Dictionary
var changeset_background : Dictionary
var is_map_ready = false
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
			if cave_noise.get_noise_2d(x,y) >0.635:
				data_dict[Vector2i(x,y)] = -1
				if y > noise_height and y <= noise_height + dirt_height:
					background_dict[Vector2i(x,y)] = 5
				elif y > noise_height + dirt_height and y <= noise_height + stone_height:
					background_dict[Vector2i(x,y)] = 6
			elif y == noise_height-1 and randi() % SPAWN_FLOWER_RATE == 0:
				data_dict[Vector2i(x,y)] = 3
			elif y == noise_height:
				data_dict[Vector2i(x,y)] = 2
			elif y > noise_height and y <= noise_height + dirt_height:
				data_dict[Vector2i(x,y)] = 0
				background_dict[Vector2i(x,y)] = 5
			elif y > noise_height + dirt_height and y <= noise_height + dirt_height + stone_height:
				data_dict[Vector2i(x,y)] = 1
				background_dict[Vector2i(x,y)] = 6
			else:
				pass 
	label_infos.text = "Génération du terrain..."
	changeset = BetterTerrain.create_terrain_changeset(tile_map, 0, data_dict)
	changeset_background = BetterTerrain.create_terrain_changeset(tile_map, 1, background_dict)

func _ready():	
	character.set_physics_process(false)
	make_map()
	
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
