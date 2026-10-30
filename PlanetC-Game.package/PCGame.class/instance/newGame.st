instance creation
newGame
	self initializeSimulation.
	(self cormasModel parameters detect: [ :p | p name = #maxSteps ]) setDefaultValueFor: self cormasModel.
	phase := 'lobby'.
	finished := false.
	session := 1.
	rangerRounds := OrderedCollection new.
	householdsWithMove := Set new.
	recorder := PCDataCollector new