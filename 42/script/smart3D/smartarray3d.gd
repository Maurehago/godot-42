@tool
@icon("res://42/script/smart3D/array_icon.svg")
extends MultiMeshInstance3D
class_name SmartArray3D

# Linear, Array, radial
# Deform
@export_category("Array")
@export var refresh:bool = false : set = _refresh

@export_group("Linear")
@export var count: int = 2 : set = _count
@export var linear_pos: Vector3 = Vector3(0.64, 0 ,0) : set = _linear_pos

@export_group("Random")
@export var random_pos: Vector3 = Vector3(0, 0 ,0) : set = _random_pos
@export var random_scale: Vector3 = Vector3(0.0, 0.0 ,0.0) : set = _random_scale
@export var random_rotation: Vector3 = Vector3(0.0, 0.0 ,0.0) : set = _random_rotation

func _linear_pos(value:Vector3):
	linear_pos = value
	calculate_pos()
	
func _count(value:int):
	count = value
	calculate_pos()

func _random_pos(value:Vector3):
	random_pos = value
	calculate_pos()

func _random_scale(value:Vector3):
	random_scale = value
	calculate_pos()

func _random_rotation(value:Vector3):
	random_rotation = value
	calculate_pos()

func _refresh(value):
	if value:
		calculate_pos()
		refresh = false
		

func calculate_pos():
	if !self.multimesh:
		return
	self.multimesh.instance_count = count
	
	# Position
	var pos:Vector3 = Vector3.ZERO

	for i in range(count):
		# Skalierung
		var rand_scale:Vector3 = Vector3(1.0, 1.0, 1.0)
		rand_scale.x = randf_range(1.0-random_scale.x, 1.0+random_scale.x)
		rand_scale.y = randf_range(1.0-random_scale.y, 1.0+random_scale.y)
		rand_scale.z = randf_range(1.0-random_scale.z, 1.0+random_scale.z)
		var rand_basis = Basis().from_scale(rand_scale)

		# Rotation
		var rand_rot:Vector3 = Vector3.ZERO
		rand_rot.x = randf_range(-random_rotation.x, +random_rotation.x)
		rand_rot.y = randf_range(-random_rotation.y, +random_rotation.y)
		rand_rot.z = randf_range(-random_rotation.z, +random_rotation.z)
		# rand_basis = rand_basis.from_euler(rand_rot)
		rand_basis = Basis.from_euler(rand_rot) * rand_basis

		# Position
		if i > 0 and i < count -1:
			var rand:Vector3 = Vector3.ZERO
			rand.x = randf_range(-1,1)*random_pos.x
			rand.y = randf_range(-1,1)*random_pos.y
			rand.z = randf_range(-1,1)*random_pos.z
			
			self.multimesh.set_instance_transform(i, Transform3D(rand_basis, pos + rand))
		else:
			self.multimesh.set_instance_transform(i, Transform3D(rand_basis, pos))
		pos += linear_pos

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	#self.multimesh = MultiMesh.new()
	#self.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	#calculate_pos()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
