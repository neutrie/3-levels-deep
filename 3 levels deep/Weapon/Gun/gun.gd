extends Node2D

const _PITCH_RANDOMNESS = 1.075
const _HIT_RANDOMNESS_PX = 4
const _RECOIL_SHAKE_AMOUNT_PX = 3
const _RECOIL_SHAKE_DURATION_SEC = 0.06

export (Array, AudioStreamSample) var _fire_sounds
export (Array, AudioStreamSample) var _hit_sounds
export (Array, AudioStreamSample) var _miss_sounds

var attack_damage = 1
var attack_rate = 9

onready var _animated_sprite = $AnimatedSprite
onready var _attack_timer = $AttackTimer
onready var _raycast = $RayCast2D

onready var _fire_sound_player = $FireSoundPlayer
onready var _hit_sound_player = $HitSoundPlayer
onready var _random_pitch_fire_stream = AudioStreamRandomPitch.new()
onready var _random_pitch_hit_stream = AudioStreamRandomPitch.new()

onready var _weapon_slot = get_parent()
onready var _weapon_holder = _weapon_slot.get_parent()

func _ready():
    randomize()
    _attack_timer.wait_time = 1.0/attack_rate
    
    _random_pitch_fire_stream.set_random_pitch(_PITCH_RANDOMNESS)
    _random_pitch_hit_stream.set_random_pitch(_PITCH_RANDOMNESS)
    _fire_sound_player.set_stream(_random_pitch_fire_stream)
    _hit_sound_player.set_stream(_random_pitch_hit_stream)


func attack():
    if not _can_attack():
        return
    _attack_timer.start()
    _animated_sprite.set_frame(0)
    _random_pitch_fire_stream.set_audio_stream(_fire_sounds[randi() % _fire_sounds.size()])
    _fire_sound_player.play()
    if not _raycast.is_colliding():
        return
    var collider = _raycast.get_collider()
    var hit_position = _raycast.get_collision_point()
    _weapon_slot.emit_signal("gun_hit", hit_position + Vector2(rand_range(-_HIT_RANDOMNESS_PX, _HIT_RANDOMNESS_PX), rand_range(-_HIT_RANDOMNESS_PX, _HIT_RANDOMNESS_PX)))
    _weapon_holder.emit_signal("shaked", _RECOIL_SHAKE_AMOUNT_PX, _RECOIL_SHAKE_DURATION_SEC)
    if "ENEMY" in collider.to_string().to_upper():
        collider.call("take_damage", attack_damage)
        _random_pitch_hit_stream.set_audio_stream(_hit_sounds[randi() % _hit_sounds.size()])
    else:
        _random_pitch_hit_stream.set_audio_stream(_miss_sounds[randi() % _miss_sounds.size()])
    _hit_sound_player.global_position = hit_position
    _hit_sound_player.play()


func _can_attack():
    return _attack_timer.is_stopped()
