extends Control

const _MUSIC_VOLUME_DB = -3
const _FADED_VOLUME_DB = -24
const _FADE_DURATION_SEC = 0.1

onready var _game_instance = preload("res://Game.tscn").instance()
onready var _tw_fade_out = $FadeOut
onready var _play_button = $PlayButton
onready var _quit_button = $QuitButton
onready var _tw_fade_out_music = $FadeOutMusic
onready var _music_player = $MusicPlayer


func _ready():
    _play_button.connect("pressed", self, "_on_play_button_pressed")
    _quit_button.connect("pressed", self, "_on_quit_button_pressed")
    _tw_fade_out_music.interpolate_property(_music_player, "volume_db",
        _MUSIC_VOLUME_DB, _FADED_VOLUME_DB, _FADE_DURATION_SEC,
        Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    _tw_fade_out.interpolate_property(self, "modulate:v",
        1, 0, _FADE_DURATION_SEC,
        Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)


func _on_play_button_pressed():
    _tw_fade_out_music.start()
    _tw_fade_out.start()
    yield(_tw_fade_out, "tween_completed")
    get_tree().root.add_child(_game_instance)
    get_tree().root.call_deferred("remove_child", self)
    call_deferred("queue_free")


func _on_quit_button_pressed():
    get_tree().quit()
