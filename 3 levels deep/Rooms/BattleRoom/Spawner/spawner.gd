extends Node2D

const _ENEMY_SCENE = preload("res://Enemy/Enemy.tscn")
const _BASE_SPAWN_DELAY_SEC = 0.725
const _SPAWN_DELAY_DECREASE_SEC = 0.025
const _ENEMY_COUNT_INCREASE = 10

var enemies_count

var _lvl
var _spawn_delay
var _left_to_spawn

onready var _spawn_points = get_children()
onready var _spawn_points_bag = _spawn_points.duplicate()

onready var _spawn_timer = Timer.new()

onready var _room = get_parent()

func _ready():
    randomize()
    _spawn_timer.one_shot = true
    _spawn_timer.autostart = false
    _spawn_timer.connect("timeout", self, "_on_spawner_timeout")
    add_child(_spawn_timer)


func set_lvl(lvl):
    _lvl = lvl
    _spawn_delay = _BASE_SPAWN_DELAY_SEC - lvl * _SPAWN_DELAY_DECREASE_SEC
    _spawn_timer.wait_time = _spawn_delay
    enemies_count = lvl * _ENEMY_COUNT_INCREASE
    _left_to_spawn = enemies_count


func activate():
    _spawn_timer.start()


func _on_spawner_timeout():
    if _left_to_spawn <= 0:
        return
    var enemy_instance = _ENEMY_SCENE.instance()
    var spawn_pos = _get_random_spawn_pos()
    enemy_instance.set_lvl(_lvl)
    enemy_instance.global_position = spawn_pos
    enemy_instance.connect("enemy_died", _room, "_on_enemy_died")
    _room.add_child(enemy_instance)
    _left_to_spawn -= 1
    _spawn_timer.start()


func _get_random_spawn_pos():
    if _spawn_points_bag.empty():
        _spawn_points_bag = _spawn_points.duplicate()
    _spawn_points_bag.shuffle()
    var spawn_pos = _spawn_points_bag.pop_front().global_position
    return spawn_pos
