extends Control

const _FADE_DURATION_SEC := 0.5

var time_sec := 0.0

onready var _tw_fade_in = $FadeIn
onready var _tw_fade_out = $FadeOut

onready var _label = $Label
onready var _play_again_button = $PlayAgainButton
onready var _quit_button = $QuitButton


func _ready():
    _label.text = "COMPLETED IN %.3f SECONDS" % time_sec
    _tw_fade_in.interpolate_property(self, "modulate:a",
        0, 1, _FADE_DURATION_SEC,
        Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    _tw_fade_out.interpolate_property(self, "modulate:v",
        1, 0, _FADE_DURATION_SEC,
        Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    _tw_fade_in.start()
    yield(_tw_fade_in, "tween_completed")
    
    _play_again_button.connect("pressed", self, "_on_play_again_button_pressed")
    _quit_button.connect("pressed", self, "_on_quit_button_pressed")


func _on_play_again_button_pressed():
    var game = get_parent().Game
    _tw_fade_out.start()
    yield(_tw_fade_out, "tween_completed")
    game.change_room(game.RoomType.START)
    call_deferred("queue_free")


func _on_quit_button_pressed():
    get_tree().quit()
