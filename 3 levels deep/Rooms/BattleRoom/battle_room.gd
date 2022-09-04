extends Node2D

const _FADE_DURATION_SEC = 0.5
const _TRAPDOOR_SCENE = preload("res://Rooms/BattleRoom/Trapdoor/Trapdoor.tscn")
const _BUTTON_SCENE = preload("res://Rooms/BattleRoom/Button/Button.tscn")
const _FINISH_SCENE = preload("res://Finish/Finish.tscn")

var _lvl
var _end_obj
var _left_to_kill

onready var Game = get_parent()
onready var _character = $Character
onready var _camera = $ShakeCamera
onready var _safezone = $Safezone
onready var _spawner = $Spawner
onready var _particle_spawner = $ParticleSpawner

onready var _tw_fade_in = $FadeIn
onready var _tw_fade_out = $FadeOut


func _ready():
    _lvl = Game.current_level
    _spawner.set_lvl(_lvl)
    _left_to_kill = _spawner.enemies_count
    match(_lvl):
        3:
            _end_obj = _BUTTON_SCENE.instance()
            _end_obj.connect("body_entered", self, "_on_button_entered")
        _:
            _end_obj = _TRAPDOOR_SCENE.instance()
            _end_obj.connect("body_entered", self, "_on_trapdoor_entered")
    $EndObjectSpawnPoint.add_child(_end_obj)
    
    _character.connect("character_died", self, "_on_character_died")
    _character.connect("shaked", _camera, "shake")
    _character.weapon.update_weapon(Game.chosen_weapon)
    _character.weapon.connect("gun_hit", _particle_spawner, "_on_gun_hit")
    _safezone.connect("body_exited", self, "_on_safezone_exited")
    
    _tw_fade_in.interpolate_property(self, "modulate:v",
        0, 1, _FADE_DURATION_SEC,
        Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    _tw_fade_out.interpolate_property(self, "modulate:v",
        1, 0, _FADE_DURATION_SEC,
        Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    _tw_fade_in.start()


func _on_safezone_exited(_body):
    _spawner.activate()
    call_deferred("remove_child", _safezone)
    _safezone.queue_free()


func _on_enemy_died():
    _left_to_kill -= 1
    if _left_to_kill > 0:
        return
    
    _end_obj.activate()
    Game.current_level += 1


func _on_character_died():
    _tw_fade_out.start()
    yield(_tw_fade_out, "tween_completed")
    Game.call_deferred("change_room", Game.RoomType.START)


func _on_trapdoor_entered(_body):
    _tw_fade_out.start()
    _character.set_active(false)
    yield(_tw_fade_out, "tween_completed")
    Game.call_deferred("change_room", Game.RoomType.BATTLE)


func _on_button_entered(_body):
    _character.set_active(false)
    yield(_end_obj.play_animation(), "completed")
    Game.is_completed = true
    var finish = _FINISH_SCENE.instance()
    finish.time_sec = Game.time_sec
    add_child(finish)
