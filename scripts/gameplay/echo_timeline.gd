class_name EchoTimeline
extends RefCounted

var _times := PackedFloat32Array()
var _positions := PackedVector2Array()


func add_sample(sample_time: float, sample_position: Vector2) -> bool:
	if sample_time < 0.0:
		return false
	if not _times.is_empty() and sample_time <= _times[-1]:
		return false

	_times.append(sample_time)
	_positions.append(sample_position)
	return true


func sample_at(sample_time: float) -> Vector2:
	if _positions.is_empty():
		return Vector2.ZERO
	if sample_time <= _times[0]:
		return _positions[0]
	if sample_time >= _times[-1]:
		return _positions[-1]

	var low := 0
	var high := _times.size() - 1
	while high - low > 1:
		var middle := (low + high) / 2
		if _times[middle] <= sample_time:
			low = middle
		else:
			high = middle

	var span := _times[high] - _times[low]
	var weight := (sample_time - _times[low]) / span
	return _positions[low].lerp(_positions[high], weight)


func duplicate_timeline() -> EchoTimeline:
	var result := EchoTimeline.new()
	result._times = _times.duplicate()
	result._positions = _positions.duplicate()
	return result


func transformed_to_anchor(anchor: Vector2, bounds: Rect2) -> EchoTimeline:
	var result := EchoTimeline.new()
	if _positions.is_empty():
		return result

	var source_origin := _positions[0]
	var direction := Vector2.ZERO
	for position in _positions:
		var offset := position - source_origin
		if offset.length() >= 24.0:
			direction = offset
			break
	if direction.is_zero_approx():
		direction = Vector2.RIGHT

	var inward := anchor.direction_to(bounds.get_center())
	var rotation := direction.angle_to(inward)
	var rotated_offsets := PackedVector2Array()
	var scale := 1.0
	for position in _positions:
		var offset := (position - source_origin).rotated(rotation)
		rotated_offsets.append(offset)
		if offset.x > 0.0:
			scale = minf(scale, (bounds.end.x - anchor.x) / offset.x)
		elif offset.x < 0.0:
			scale = minf(scale, (anchor.x - bounds.position.x) / -offset.x)
		if offset.y > 0.0:
			scale = minf(scale, (bounds.end.y - anchor.y) / offset.y)
		elif offset.y < 0.0:
			scale = minf(scale, (anchor.y - bounds.position.y) / -offset.y)
	scale = clampf(scale, 0.0, 1.0)

	for index in _times.size():
		result.add_sample(_times[index], anchor + rotated_offsets[index] * scale)
	return result


func sample_count() -> int:
	return _positions.size()


func duration() -> float:
	if _times.is_empty():
		return 0.0
	return _times[-1]


func travel_distance() -> float:
	var distance := 0.0
	for index in range(1, _positions.size()):
		distance += _positions[index - 1].distance_to(_positions[index])
	return distance


func is_playable() -> bool:
	return sample_count() >= 2 and duration() > 0.0
