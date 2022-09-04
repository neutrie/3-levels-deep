extends Node2D

# warning-ignore:unused_signal
signal gun_hit(hit_position)

const _GUN_SCENE = preload("res://Weapon/Gun/Gun.tscn")
const _SWORD_SCENE = preload("res://Weapon/Sword/Sword.tscn")
var _current_weapon = null


func update_weapon(weapon):
    if _current_weapon != null:
        remove_child(_current_weapon)
        _current_weapon.queue_free()
    
    match weapon:
        "GUN":
            _current_weapon = _GUN_SCENE.instance()
        "SWORD":
            _current_weapon = _SWORD_SCENE.instance()
    call_deferred("add_child", _current_weapon)


func attack():
    if _current_weapon == null:
        return
    _current_weapon.attack()
