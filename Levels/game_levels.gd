extends Node2D

var startTime = 0

func _ready():
	startTime = Time.get_ticks_msec()


func update_clock():
	var currentTime = Time.get_ticks_msec() - startTime # Calcule le temps écoulé en millisecondes
	var seconds = int(currentTime / 1000) # Convertit les millisecondes en secondes
	var minutes = int(seconds / 60) # Convertit les secondes en minutes
	var hours = int(minutes / 60) # Convertit les minutes en heures
	$Label.text = "Temps écoulé : " + str(hours) + ":" + str(minutes % 60) + ":" + str(seconds % 60)
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta):
	
	update_clock()



# Called when the node enters the scene tree for the first time.

