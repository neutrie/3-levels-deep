extends Node2D

const _PITCH_RANDOMNESS = 1.075
const _RECOIL_SHAKE_AMOUNT_PX = 10
const _RECOIL_SHAKE_DURATION_SEC = 0.15

export (Array, AudioStreamSample) var _attack_sounds
export (Array, AudioStreamSample) var _whoosh_sounds

var attack_damage = 6
var attack_rate = 1.66

onready var _animated_sprite = $AnimatedSprite
onready var _attack_timer = $AttackTimer
onready var _area = $Area2D
onready var _splash = $Splash

onready var _sound_player = $SoundPlayer
onready var _random_pitch_stream = AudioStreamRandomPitch.new()

onready var _weapon_holder = get_parent().get_parent()


func _ready():
    randomize()
    _attack_timer.wait_time = 1.0/attack_rate
    
    _random_pitch_stream.set_random_pitch(_PITCH_RANDOMNESS)
    _sound_player.set_stream(_random_pitch_stream)


func attack():
    if not _can_attack():
        return
    _attack_timer.start()
    _random_pitch_stream.set_audio_stream(_whoosh_sounds[randi() % _whoosh_sounds.size()])
    _animated_sprite.set_frame(0)
    _sound_player.play()
    yield(_animated_sprite, "animation_finished")
    _weapon_holder.emit_signal("shaked", _RECOIL_SHAKE_AMOUNT_PX, _RECOIL_SHAKE_DURATION_SEC)
    _splash.set_frame(0)
    _splash.play("spawn")
    var bodies = _area.get_overlapping_bodies()
    _random_pitch_stream.set_audio_stream(_attack_sounds[randi() % _attack_sounds.size()])
    _sound_player.play()
    for body in bodies:
        body.call("take_damage", attack_damage)


func _can_attack():
    return _attack_timer.is_stopped()
