# meta-name: TopDown Movement 
# meta-description: Bewegungsvorlage für einen Spieler der sich auf einer Ebene bewegt und immer in Richtung der Maus schaut.
# meta-default: true
# meta-space-indent: 4
extends CharacterBody2D

# Einstellbare Werte
@export var speed: float = 150.0 		# Geschwindigkeit des Spilers in Pixel /Sekunde
@export var min_abstand: float = 30.0	# Minimaler Abstand zwischen Spieler und Maus 

var is_colliding: bool = false 	# wenn Kolidiert
var mouse_position: Vector2		# letzte Maus Position 

# Tastatur Eingabe Festlegen
func _set_inputs():
	# Tasten Codes
	var new_foreward = InputEventKey.new()
	var new_back = InputEventKey.new()
	var new_left = InputEventKey.new()
	var new_right = InputEventKey.new()

	new_foreward.keycode = KEY_W
	new_back.keycode = KEY_S
	new_left.keycode = KEY_A
	new_right.keycode = KEY_D
	
	# Zuordnung speichern wenn noch nicht vorhanden
	if !InputMap.has_action("move_foreward"):
		InputMap.add_action("move_foreward")
		InputMap.action_add_event("move_foreward", new_foreward)
	if !InputMap.has_action("move_back"):
		InputMap.add_action("move_back")
		InputMap.action_add_event("move_back", new_back)
	if !InputMap.has_action("move_left"):
		InputMap.add_action("move_left")
		InputMap.action_add_event("move_left", new_left)
	if !InputMap.has_action("move_right"):
		InputMap.add_action("move_right")
		InputMap.action_add_event("move_right", new_right)


# Beim Start ausführen
func _ready():
	# Tastenzuordnung festlegen
	_set_inputs()

func _process(_delta):
	# Richtung für bewegung
	var direction: Vector2 = Vector2.ZERO

	# Spieler in die richtung der Maus drehen
	mouse_position =  get_global_mouse_position()
	self.look_at(mouse_position)
	
	# Mindestabstand Prüfen
	# wenn dieser erreicht ist, darf sich der Spieler nicht mehr vorwärts bewegen
	if self.global_position.distance_to(mouse_position) > min_abstand:
		if Input.is_action_pressed("move_foreward"):
			direction.x += 1

	if Input.is_action_pressed("move_back"):
		direction.x -= 1

	if Input.is_action_pressed("move_left"):
		direction.y -= 1
		pass
	if Input.is_action_pressed("move_right"):
		direction.y += 1
		pass

	# drehen
	direction = self.global_transform.basis_xform(direction)
	
	# Bewegung dem CharacterBody2D zuweisen
	velocity = direction.normalized() * speed
	
func _physics_process(_delta):
	# Spieler bewegen
	is_colliding = move_and_slide()
