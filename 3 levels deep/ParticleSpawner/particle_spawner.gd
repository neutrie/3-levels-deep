extends Node2D

const _GUN_HIT_PARTICLES = preload("res://ParticleSpawner/GunHit.tscn")
const _GUN_HIT_ANIM_COUNT = 2

func _on_gun_hit(hit_position):
    var gun_hit_particles_instance = _GUN_HIT_PARTICLES.instance()
    gun_hit_particles_instance.global_position = hit_position
    add_child(gun_hit_particles_instance)
    gun_hit_particles_instance.play(str(randi() % _GUN_HIT_ANIM_COUNT))
    yield(gun_hit_particles_instance, "animation_finished")
    remove_child(gun_hit_particles_instance)
    gun_hit_particles_instance.queue_free()
