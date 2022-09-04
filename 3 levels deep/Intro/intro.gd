extends Control

signal intro_read

const _ENGRAVING_FADE_TIME = 1.2
const _CONTINUE_FADE_TIME = 0.75

onready var _tw_fade_in = $Fadein
onready var _skip_timer = $SkipTimer
onready var _image = $Image
onready var _continue = $Continue


func _ready():
    _tw_fade_in.interpolate_property(_image, "modulate:a",
        0, 1, _ENGRAVING_FADE_TIME,
        Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    _tw_fade_in.interpolate_property(_continue, "modulate:a",
        0, 1, _CONTINUE_FADE_TIME,
        Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, _ENGRAVING_FADE_TIME)
    _tw_fade_in.start()
    _skip_timer.start()


func _unhandled_key_input(_event):
    if not _skip_timer.is_stopped():
        return
    emit_signal("intro_read")
    queue_free()
