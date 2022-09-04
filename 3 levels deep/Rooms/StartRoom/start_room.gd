extends Node2D

const _FADE_DURATION_SEC = 0.5

const _INTRO_SCENE = preload("res://Intro/Intro.tscn")
var _intro_instance = null

onready var Game = get_parent()
onready var _character = $Character
onready var _camera = $ShakeCamera
onready var _gun_trigger = $GunTrigger
onready var _sword_trigger = $SwordTrigger
onready var _intro_trigger = $IntroTrigger
onready var _door = $Door
onready var _particle_spawner = $ParticleSpawner

onready var _tw_fade_in = $FadeIn
onready var _tw_fade_out = $FadeOut


func _ready():
    if not Game.is_intro_read:
        _intro_trigger.connect("body_entered", self, "_on_intro_trigger_entered")
        _intro_instance = _INTRO_SCENE.instance()
        _intro_instance.connect("intro_read", self, "_on_intro_read")
    else:
        remove_child(_intro_trigger)
        _intro_trigger.queue_free()
    
    _character.connect("shaked", _camera, "shake")
    _character.weapon.connect("gun_hit", _particle_spawner, "_on_gun_hit")
    _character.show_healthbar(false)
    _gun_trigger.connect("body_entered", self, "_on_gun_trigger_entered")
    _sword_trigger.connect("body_entered", self, "_on_sword_trigger_entered")
    _door.connect("body_entered", self, "_on_door_entered")

    _tw_fade_in.interpolate_property(self, "modulate:v",
        0, 1, _FADE_DURATION_SEC,
        Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    _tw_fade_out.interpolate_property(self, "modulate:v",
        1, 0, _FADE_DURATION_SEC,
        Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    
    _tw_fade_in.start()
    
    Game.current_level = 1
    Game.time_sec = -1.0
    Game.is_completed = false
    Game.chosen_weapon = null


func _on_gun_trigger_entered(_body):
    if Game.chosen_weapon == "GUN":
        return
    _character.weapon.update_weapon("GUN")
    Game.chosen_weapon = "GUN"
    _gun_trigger.get_node("EquipSound").play()
    _gun_trigger.get_node("EquipParticles").set_frame(0)


func _on_sword_trigger_entered(_body):
    if Game.chosen_weapon == "SWORD":
        return
    _character.weapon.update_weapon("SWORD")
    Game.chosen_weapon = "SWORD"
    _sword_trigger.get_node("EquipSound").play()
    _sword_trigger.get_node("EquipParticles").set_frame(0)


func _on_intro_trigger_entered(_body):
    _character.set_active(false)
    add_child(_intro_instance)
    call_deferred("remove_child", _intro_trigger)
    _intro_trigger.queue_free() 


func _on_intro_read():
    Game.is_intro_read = true
    remove_child(_intro_instance)
    _intro_instance.queue_free()
    _character.set_active(true)


func _on_door_entered(_body):
    if Game.chosen_weapon == null:
        return
    _door.get_node("AnimatedSprite").play("open")
    _door.get_node("OpenSound").play()
    _tw_fade_out.start()
    _character.set_active(false)
    yield(_tw_fade_out, "tween_completed")
    Game.call_deferred("change_room", Game.RoomType.BATTLE)
    Game.time_sec = 0.0
