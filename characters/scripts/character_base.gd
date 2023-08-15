extends CharacterBody2D

class_name BaseCharacter

@onready var anim: AnimationPlayer = $Anim
@onready var texture: Sprite2D = $Texture

var _is_attacking := false
var _state_machine: AnimationNodeStateMachinePlayback = null
@export var _move_speed := 64.0

@export_category("Objects")
@export var _animation_tree: AnimationTree = null
@export var _attack_timer: Timer = null

func _ready() -> void:
	_animation_tree.active = true
	_state_machine = _animation_tree["parameters/playback"]
	
	
func _physics_process(_delta: float) -> void:
	_move()
	_attack()
	_animate()
	move_and_slide()
	
	
func _move() -> void:
	var _direction: Vector2 = Input.get_vector(
		"ui_left", "ui_right", #horizontal
		"ui_up", "ui_down"     #vertical
	)
	if _direction:
		_animation_tree["parameters/idle/blend_position"] = _direction
		_animation_tree["parameters/walk/blend_position"] = _direction
		_animation_tree["parameters/attack/blend_position"] = _direction
	velocity = _direction * _move_speed
	
func _attack() -> void:
	if Input.is_action_just_pressed("attack") and not _is_attacking:
		set_physics_process(false)
		_attack_timer.start(0.2)
		_is_attacking = true
	
	
func _animate() -> void:
	if _is_attacking:
		_state_machine.travel("attack")
		return
		
	if velocity:  # -> if velocity != Vector2.ZERO
		_state_machine.travel("walk")
		return
		
	_state_machine.travel("idle")
	
func _on_attack_timer_timeout() -> void:
	set_physics_process(true)
	_is_attacking = false
