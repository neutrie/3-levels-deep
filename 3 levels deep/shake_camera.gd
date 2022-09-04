extends Camera2D

const _NOISE_SHAKE_SPEED = 150
const _NOISE_X_OFFSET_FACTOR = 5
const _OFFSET_RESET_DURATION_SEC = 0.02

var _default_offset = offset
var _shake_amount = 0
var _noise_y = 0

onready var _shake_timer = $ShakeTimer
onready var _tw_reset = $ResetTween
onready var _noise = OpenSimplexNoise.new()


func _ready():
    randomize()
    _noise.seed = randi()
    _noise.period = 4
    _noise.octaves = 2
    _shake_timer.connect("timeout", self, "_on_timer_timeout")
    set_process(false)


func _process(delta):
    offset = _default_offset + _get_noise_offset(delta) * _shake_amount


func shake(new_shake, shake_duration):
    _shake_amount = new_shake
    _shake_timer.wait_time = shake_duration
    _tw_reset.stop_all()
    set_process(true)
    _shake_timer.start()


func _get_noise_offset(delta):
    _noise_y += _NOISE_SHAKE_SPEED * delta
    return Vector2(
        _noise.get_noise_2d(_noise.seed, _noise_y),
        _noise.get_noise_2d(_noise.seed * _NOISE_X_OFFSET_FACTOR, _noise_y)
       )


func _on_timer_timeout():
    _shake_amount = 0
    set_process(false)
    _tw_reset.interpolate_property(self, "offset",
        offset, _default_offset, _OFFSET_RESET_DURATION_SEC,
        Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
    _tw_reset.start()
