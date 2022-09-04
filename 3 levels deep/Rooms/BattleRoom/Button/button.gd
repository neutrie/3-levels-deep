extends Area2D

onready var _animated_sprite = $AnimatedSprite
onready var _collision_shape = $CollisionShape2D
onready var _activate_particles = $ActivateParticles
onready var _activate_sound = $ActivateSound
onready var _press_sound = $PressSound


func activate():
    _activate_sound.play()
    _collision_shape.disabled = false
    _activate_particles.set_frame(0)


func play_animation():
    _press_sound.play()
    _animated_sprite.play("press")
    yield(_animated_sprite, "animation_finished")
