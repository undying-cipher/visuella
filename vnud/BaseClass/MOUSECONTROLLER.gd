extends Node2D
class_name MOUSECONTROLLER

var hovered_areas: Array[OBJECT] = []

func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		update_hovered_areas()
	if event is InputEventMouseButton:
		if event.is_action_pressed("Click") and hovered_areas.size() > 0:
			hovered_areas[0].interact()

func update_hovered_areas()-> void:
	var world: PhysicsDirectSpaceState2D = get_viewport().world_2d.direct_space_state
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var query: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	query.position = mouse_pos
	query.collision_mask = 1
	query.collide_with_bodies = false
	query.collide_with_areas = true

	var results: Array[Dictionary] = world.intersect_point(query)
	var current_hovered: Array[OBJECT] = []

	for result: Dictionary in results:
		if "collider" in result and result["collider"] is OBJECT:
			var obj = result["collider"]
			current_hovered.append(obj)
			if obj not in hovered_areas:
				hovered_areas.append(obj)
				obj.hovered()

	for obj: OBJECT in hovered_areas:
		if obj not in current_hovered:
			obj.unhovered()  

	hovered_areas = current_hovered
