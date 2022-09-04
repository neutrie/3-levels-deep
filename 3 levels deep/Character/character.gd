extends KinematicBody2D

signal character_died
signal shaked(amount, duration)

const _PITCH_RANDOMNESS = 1.075
const _HIT_SHAKE_AMOUNT_PX = 20
const _HIT_SHAKE_DURATION_SEC = 0.1

const _ACCELERATION = 1000
const _MAX_MOVEMENT_SPEED = 200
const _MOVEMENT_SPEED_PENALTY = 0.25

export (Array, AudioStreamSample) var _hurt_sounds

var _hp = 3
var _movement_speed = 0
var _velocity = Vector2.ZERO


onready var weapon = $Weapon
onready var _animated_sprite = $AnimatedSprite
onready var _invul_timer = $InvulnerabilityTimer
onready var _healthbar = $Healthbar

onready var _sound_player = $SoundPlayer
onready var _random_pitch_stream = AudioStreamRandomPitch.new()


func _ready():
    randomize()
    _healthbar.set_healthbar_type(_hp)
    _healthbar.set_hp(_hp)
    _random_pitch_stream.set_random_pitch(_PITCH_RANDOMNESS)
    _sound_player.set_stream(_random_pitch_stream)


func _process(_delta):
    _process_input()


func _physics_process(delta):
    _process_movement(delta)
# warning-ignore:return_value_discarded
    move_and_collide(_velocity * delta)


func set_active(enabled):
    _invul_timer.paused = not enabled
    set_process(enabled)
    _velocity = Vector2.ZERO
    yield(get_tree(), "idle_frame")
    set_physics_process(enabled)


func show_healthbar(enabled):
# warning-ignore:standalone_ternary
    _healthbar.show() if enabled else _healthbar.hide()


func take_damage(amount):
    if not _can_take_damage():
        return
    _invul_timer.start()
    _random_pitch_stream.set_audio_stream(_hurt_sounds[randi() % _hurt_sounds.size()])
    _sound_player.play()
    _hp -= amount
    _movement_speed *= 1 - _MOVEMENT_SPEED_PENALTY
    _healthbar.set_hp(_hp)
    emit_signal("shaked", _HIT_SHAKE_AMOUNT_PX, _HIT_SHAKE_DURATION_SEC)
    if _hp <= 0:
        _die()


func _can_take_damage():
    return _invul_timer.is_stopped()


func _die():
    weapon.hide()
    set_active(false)
    _animated_sprite.play("death")
    yield(_animated_sprite, "animation_finished")
    emit_signal("character_died")



func _process_input():
    _velocity = Vector2.ZERO
    if Input.is_action_pressed("move_up"):
        _velocity.y -= 1
    if Input.is_action_pressed("move_down"):
        _velocity.y += 1
    if Input.is_action_pressed("move_right"):
        _velocity.x += 1
    if Input.is_action_pressed("move_left"):
        _velocity.x -= 1
    if Input.is_action_pressed("attack1"):
        weapon.attack()


func _process_movement(delta):
    if _velocity.length() > 0:
        _movement_speed = min(_movement_speed + _ACCELERATION * delta, _MAX_MOVEMENT_SPEED)
        _velocity = _velocity.normalized() * _movement_speed
        if not _animated_sprite.is_playing():
            _animated_sprite.play("move")
    else:
        _movement_speed = max(_movement_speed - _ACCELERATION * delta, 0)
        _animated_sprite.frame = 0
        _animated_sprite.stop()
    
    var mouse_global_pos = get_global_mouse_position()
    var mouse_dir = global_position.direction_to(mouse_global_pos)
    rotation = mouse_dir.angle()
    weapon.look_at(mouse_global_pos)
