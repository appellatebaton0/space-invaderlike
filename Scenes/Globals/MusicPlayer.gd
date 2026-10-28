extends AudioStreamPlayer

var current := 1

func _process(delta: float) -> void:
	if stream is AudioStreamSynchronized:
		
		for i in stream.stream_count:
			
			var vol := db_to_linear(stream.get_sync_stream_volume(i))
			vol = move_toward(vol, 1.0 if current == i else 0.0, delta * 0.25)
			
			stream.set_sync_stream_volume(i, linear_to_db(vol))

var names := ["Game", "Menu"]
func transition(to:String):
	current = names.find(to)
