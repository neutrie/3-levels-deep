extends AnimatedSprite

const _OFFSET = Vector2(0, -30)
onready var _parent = get_parent()


func _process(_delta):
    set_rotation(- _parent.rotation)
    set_global_position(_parent.global_position + _OFFSET)


func set_healthbar_type(healthbar_type):
    set_animation(str(healthbar_type))


func set_hp(hp):
    set_frame(hp)
