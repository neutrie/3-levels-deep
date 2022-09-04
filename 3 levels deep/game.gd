extends Node2D

enum RoomType {START, BATTLE}

const _MUSIC_VOLUME_DB = -3
const _FADED_VOLUME_DB = -24
const _MUSIC_TRANS_DURATION_SEC = 0.1

const _START_ROOM_SCENE = preload("res://Rooms/StartRoom/StartRoom.tscn")
const _BATTLE_ROOM_SCENE = preload("res://Rooms/BattleRoom/BattleRoom.tscn")

export var _start_loop: AudioStreamSample
export var _battle_loop: AudioStreamSample

var chosen_weapon = null
var is_intro_read := false
var time_sec := -1.0
var current_level := 1
var is_completed := false

var _current_room = null

onready var _music_player = $MusicPlayer
onready var _tw_fade_in_music = $MusicPlayer/FadeInMusic
onready var _tw_fade_out_music = $MusicPlayer/FadeOutMusic
onready var _crosshair = $Crosshair


func _ready():
    Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
    change_room(RoomType.START)


func _process(delta):
    if Input.is_action_pressed("exit"):
        get_tree().quit()
    _crosshair.global_position = get_global_mouse_position()
    _add_battle_time(delta)


func change_room(room_type):
    if _current_room != null:
        remove_child(_current_room)
        _current_room.queue_free()
    match room_type:
        RoomType.START:
            change_music(_start_loop)
            _current_room = _START_ROOM_SCENE.instance()
        RoomType.BATTLE:
            change_music(_battle_loop)
            _current_room = _BATTLE_ROOM_SCENE.instance()
    add_child(_current_room)


func change_music(new_music):
    var current_music = _music_player.get_stream()
    if current_music == new_music:
        return
    _tw_fade_out_music.interpolate_property(_music_player, "volume_db",
        _MUSIC_VOLUME_DB, _FADED_VOLUME_DB, _MUSIC_TRANS_DURATION_SEC,
        Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    _tw_fade_in_music.interpolate_property(_music_player, "volume_db",
        _FADED_VOLUME_DB, _MUSIC_VOLUME_DB, _MUSIC_TRANS_DURATION_SEC,
        Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    if current_music != null:
        _tw_fade_out_music.start()
        yield(_tw_fade_out_music, "tween_completed")
    _music_player.set_stream(new_music)
    _music_player.play()
    _tw_fade_in_music.start()


func _add_battle_time(delta):
    if time_sec == -1.0 or is_completed:
        return
    time_sec += delta
