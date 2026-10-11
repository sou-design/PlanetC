initialization
initialize
	super initialize.
	phase := 'lobby'.
	recorder := PCDataCollector new.
	server := PCGameServer new.
	server game: self