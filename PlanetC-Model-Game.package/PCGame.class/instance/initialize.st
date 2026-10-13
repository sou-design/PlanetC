initialization
initialize
	super initialize.
	phase := 'lobby'.
	recorder := PCDataCollector new.
	rangerRounds := OrderedCollection new.
	server := PCGameServer new.
	server game: self