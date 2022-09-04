extends KinematicBody2D

signal enemy_died

const _BASE_MOVEMENT_SPEED = 95
const _MOVEMENT_SPEED_INCREASE = 15
const _BASE_HP = 2

const _BLOOD_ANIM_COUNT = 2
const _BLOOD_POS_RANDOMNESS_PX = 6
const _PITCH_RANDOMNESS = 1.075
const _KNOCKBACK_AMOUNT = 4
const _FADE_OUT_DURATION_SEC = 0.75

export (Array, AudioStreamSample) var _hurt_sounds

var _lvl
var _hp
var _movement_speed
var _velocity = Vector2.ZERO
var _collision_info

onready var _character = get_parent().get_node("Character")

onready var _tw_fade_out = $FadeOut
onready var _animated_sprite = $AnimatedSprite
onready var _collision_shape = $CollisionShape2D
onready var _spawn_particles = $SpawnParticles
onready var _blood = $Blood
onready var _healthbar = $Healthbar

onready var _sound_player = $SoundPlayer
onready var _random_pitch_stream = AudioStreamRandomPitch.new()

func _ready():
    randomize()
    _tw_fade_out.interpolate_property(self, "modulate:a",
        1, 0, _FADE_OUT_DURATION_SEC,
        Tween.TRANS_QUAD, Tween.EASE_IN)
    _healthbar.set_healthbar_type(_hp)
    _healthbar.set_hp(_hp)
    _animated_sprite.set_animation(str(_lvl))
    
    _random_pitch_stream.set_random_pitch(_PITCH_RANDOMNESS)
    _sound_player.set_stream(_random_pitch_stream)
    _create_spawn_particles()


func _physics_process(delta):
    _chase_target(_character)
    _collision_info = move_and_collide(_velocity * delta)
    _process_collision()


func set_lvl(lvl):
    _lvl = lvl
    _hp = _BASE_HP + lvl
    _movement_speed = _BASE_MOVEMENT_SPEED + lvl * _MOVEMENT_SPEED_INCREASE


func take_damage(amount):
    _display_blood()
    _random_pitch_stream.set_audio_stream(_hurt_sounds[randi() % _hurt_sounds.size()])
    _sound_player.play()
    _hp -= amount
    _healthbar.set_hp(0 if _hp < 0 else _hp)
    _apply_knockback(rotation)
    if _hp <= 0:
        _die()


func _die():
    _collision_shape.disabled = true
    set_physics_process(false)
    _animated_sprite.play("death")
    _tw_fade_out.start()
    yield(_tw_fade_out, "tween_completed")
    emit_signal("enemy_died")
    queue_free()


func _chase_target(target):
    var target_pos = target.global_position
    look_at(target_pos)
    _velocity = global_position.direction_to(target_pos) * _movement_speed


func _process_collision():
    if _collision_info == null:
        return
    var collider = _collision_info.get_collider()
    if "CHARACTER" in collider.to_string().to_upper():
        collider.call("take_damage", 1)


func _create_spawn_particles():
    _spawn_particles.set_frame(0)
    yield(_spawn_particles, "animation_finished")
    _spawn_particles.queue_free()


func _display_blood():
    _blood.offset = Vector2(rand_range(-_BLOOD_POS_RANDOMNESS_PX, _BLOOD_POS_RANDOMNESS_PX), rand_range(-_BLOOD_POS_RANDOMNESS_PX, _BLOOD_POS_RANDOMNESS_PX))
    _blood.set_frame(0)
    _blood.play(str(randi() % _BLOOD_ANIM_COUNT))


func _apply_knockback(rot):
    var knockback_dir = Vector2(cos(rot - PI), sin(rot - PI))
# warning-ignore:return_value_discarded
    move_and_collide(knockback_dir * _KNOCKBACK_AMOUNT)
