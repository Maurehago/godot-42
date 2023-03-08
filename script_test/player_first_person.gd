# meta-name: 3D First Person Movement 
# meta-description: Bewegungsvorlage für einen Spieler aus Kamera Sicht
# meta-default: true
# meta-space-indent: 4
extends CharacterBody3D

@export var max_speed: float = 5.0 			# Geschwindigkeit des Spielers
@export var accel: float = 0.5 			# Beschleunigung des Spielers
@export var deaccel: float = 1.0 			# Abbremsen des Spielers
@export var jump_velocity: float = 4.5	# Sprunghöhe
@export var mouse_sensivity: float =  0.25	# Geschwindigkeit der Mausdrehung
@export var invert_mouse_y := false
@export var invert_mouse_x := false
#@export var gravity_vector :Vector3 = Vector3(0.0, -1.0, 0.0)	# Richtung der Gravitation

@export var camera : Camera3D

var mouse_captured := false	# Merkt sich ob die Maus gefangen ist
const min_camRotX := -PI/2	# kleinster Winkel in radians bis zu dem man nach unten sehen kann
const max_camRotX := PI/2	# größter Winkel in radians bis zu dem man nach oben sehen kann
var direction := Vector3.ZERO	# Tasten Bewegungs Richtung


# Gravitation von den Projekt Einstellungen laden damit diese mit den RigidBody Nodes synchron ist.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


# Tastatur Eingabe Festlegen
func _set_inputs():
	# Tasten Codes
	var new_foreward = InputEventKey.new()
	var new_back = InputEventKey.new()
	var new_left = InputEventKey.new()
	var new_right = InputEventKey.new()
	var new_jump = InputEventKey.new()
	var new_switchmode = InputEventKey.new()

	new_foreward.keycode = KEY_W
	new_back.keycode = KEY_S
	new_left.keycode = KEY_A
	new_right.keycode = KEY_D
	new_jump.keycode = KEY_SPACE
	new_switchmode.keycode = KEY_TAB
	
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
	if !InputMap.has_action("move_jump"):
		InputMap.add_action("move_jump")
		InputMap.action_add_event("move_jump", new_jump)
	if !InputMap.has_action("switchmode"):
		InputMap.add_action("switchmode")
		InputMap.action_add_event("switchmode", new_switchmode)


# Beim Start ausführen
func _ready() -> void:
	if camera == null:
		push_warning("player_first_person.gd: Keine Kamera im Inspektor festgelegt. Suche nach Camera3D...")
		for child in get_children():
			if child is Camera3D:
				camera = child
	
	# Tastenzuordnung festlegen
	_set_inputs()
	
	# Maus fangen
	capture_mouse()

# Eingaben prüfen
func _input(event):
	# Wenn Maus Bewegung (Umschauen)
	if event is InputEventMouseMotion:
		var x_multiplier = -1 if invert_mouse_x else 1
		var y_multiplier = -1 if invert_mouse_y else 1
		rotate_y(-event.relative.x * 0.01 * mouse_sensivity * x_multiplier)
		camera.rotate_x(-event.relative.y * 0.01 * mouse_sensivity * y_multiplier)
		
		camera.rotation.x = clampf(camera.rotation.x, min_camRotX, max_camRotX)


func _process(delta) -> void:
	# Maus Fang Modus umschalten
	if Input.is_action_just_pressed("switchmode"):
		capture_mouse()
		
	if !mouse_captured:
		return

	# Bewegungsrichtung bestimmen
	var input_vector = Input.get_vector("move_left", "move_right", "move_back", "move_foreward")
	# Richtung Normalisieren, so dass in alle Richtungen die Geschwindigkeit konstant ist
	direction = (global_transform.basis.x * input_vector.x + -global_transform.basis.z * input_vector.y).normalized()


func _physics_process(delta) -> void:
	# Gravitation berücksichtigen
	if not is_on_floor():
		velocity.y -= gravity * delta
	# Springen
	elif Input.is_action_just_pressed("move_jump"):
		velocity.y += jump_velocity
	
	var accel_to_use = accel if direction != Vector3.ZERO else deaccel
	velocity = velocity.move_toward(Vector3(max_speed, velocity.y, max_speed) * Vector3(direction.x, 1, direction.z), accel_to_use)
	move_and_slide()


# zwischen Maus und Spielerbewegung umschalten
func capture_mouse() -> void:
	mouse_captured = !mouse_captured
	if mouse_captured:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
