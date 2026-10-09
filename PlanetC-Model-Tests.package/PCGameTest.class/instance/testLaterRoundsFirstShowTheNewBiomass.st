tests
testLaterRoundsFirstShowTheNewBiomass
	model currentRound: 2.
	self phase: 'ready'.
	self assert: (game proceed: 30) equals: 'ok'.
	self assert: game phase equals: 'newBiomass'.
	self allPlayers do: [ :p |
		self assert: ((p lastMessageOfType: 'round') at: 'round') equals: 2.
		self assert: (p hasReceived: 'biomass').
		self deny: (p hasReceived: 'turn') ]













