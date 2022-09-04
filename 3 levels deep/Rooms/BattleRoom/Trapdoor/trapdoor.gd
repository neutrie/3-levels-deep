extends Area2D

onready var _animated_sprite = $AnimatedSprite
onready var _collision_shape = $CollisionShape2D
onready var _open_sound = $OpenSound


func activate():
    _animated_sprite.play("open")
    _open_sound.play()
    yield(_animated_sprite, "animation_finished")
    _collision_shape.disabled = false
