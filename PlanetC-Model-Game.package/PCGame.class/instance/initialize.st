initialization
initialize
	super initialize.
	phase := 'lobby'.
	server := PCGameServer new.
	server game: self