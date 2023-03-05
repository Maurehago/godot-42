# meta-name: 3D First Person Movement 
# meta-description: Bewegungsvorlage für einen Spieler aus Kamera Sicht
# meta-default: true
# meta-space-indent: 4
extends CharacterBody3D

@export var speed: float = 5.0 			# Geschwindigkeit des Spilers
@export var jump_velocity: float = 4.5	# Sprunghöhe
@export var mouse_sensivity: float =  0.25	# Geschwindigkeit der Mausdrehung
#@export var gravity_vector :Vector3 = Vector3(0.0, -1.0, 0.0)	# Richtung der Gravitation
@export_node_path("Camera3D") var camera	# Spieler Kamera

var cam:Camera3D

var mouse_captured: bool = false;	# Merkt sich ob die Maus gefangen ist
var min_camRotX :float = -1.3	# kleinstr Winkel in radians bis zu dem man nach unten sehen kann
var max_camRotX :float = 1.5	# größter Winkel in radians bis zu dem man nach oben sehen kann
var direction: Vector3 = Vector3.ZERO	# Tasten Bewegungs Richtung
var mouse_relative:Vector2 = Vector2.ZERO

# Gravitation von den Projekt Einstellungen laden damit diese mit den RigidBody Nodes synchron ist.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

const SPEED = 5.0
const JUMP_VELOCITY = 4.5



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
	# Kamera bestimmen
	cam = get_node(camera)
	
	# Tastenzuordnung festlegen
	_set_inputs()
	
	# Maus fangen
	capture_mouse()

# Eingaben prüfen
func _input(event):
	# Wenn Maus Bewegung (Umschauen)
	if event is InputEventMouseMotion:
		# relative Mausbewegung merken
		mouse_relative = event.relative


func _process(delta) -> void:
	# Maus Fang Modus umschalten
	if Input.is_action_just_pressed("switchmode"):
		capture_mouse()
		
	if !mouse_captured:
		return
		
	# ============
	# drehen 
	
	# Horizontal - Kamera nach Oben und Unten schwenken
	# relative Mausbewegung merken
	var rel_rotation = mouse_relative.x * delta * mouse_sensivity *-1
	self.rotate_y(rel_rotation)

	# Vertikal
	var cam_rotation: float = -mouse_relative.y * delta
	var rotate = cam.rotation.x + cam_rotation
	if rotate > min_camRotX and rotate < max_camRotX: 
		cam.rotate_x(cam_rotation)
	mouse_relative = Vector2.ZERO # zurücksetzen sonnst bleibt Unendlich ein Wert drinnen
	# =====================

	# Bewegungsrichtung bestimmen
	direction = Vector3.ZERO
	var player_vec = self.global_transform.basis # Aktuelle Ausrichtung des Spieler merken
	
	# Tasten Eingaben prüfen
	if Input.is_action_pressed("move_foreward"):
		direction -= player_vec.z	# -Z ist vorwärts!
	if Input.is_action_pressed("move_back"):
		direction += player_vec.z
	if Input.is_action_pressed("move_left"):
		direction -= player_vec.x
	if Input.is_action_pressed("move_right"):
		direction += player_vec.x
	
	# Richtung Normalisieren, so dass in alle Richtungen die Geschwindigkeit konstant ist
	direction = direction.normalized()
	
	# eigene BewegungsRichtung festlegen
	#self.velocity = direction * speed # + Vector3(0, -9.8, 0)


func _physics_process(delta) -> void:
	# Gravitation berücksichtigen
	if not is_on_floor():
		#direction += gravity_vector * gravity * delta
		velocity.y -= gravity * delta

	# Springen prüfen
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		#direction += -gravity_vector * jump_velocity
		velocity.y += jump_velocity

	# wenn Bewegunsrichtung
	if direction:
		#velocity = direction * speed
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		# weiter bewegen ???
		velocity.x = move_toward(velocity.x, 0, speed)
		#velocity.y = move_toward(velocity.y, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

# zwischen Maus und Spielerbewegung umschalten
func capture_mouse() -> void:
	mouse_captured = !mouse_captured
	if mouse_captured:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
