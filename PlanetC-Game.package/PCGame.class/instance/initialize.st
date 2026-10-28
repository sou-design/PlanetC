initialization
initialize
	super initialize.
	phase := 'lobby'.
	finished := false.
	session := 1.
	recorder := PCDataCollector new.
	rangerRounds := OrderedCollection new.
	householdsWithMove := Set new.
	server := PCGameServer new.
	server game: self