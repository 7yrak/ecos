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
