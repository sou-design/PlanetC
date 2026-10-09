tests
testStartGame
	game activeInitSelector: #init.
	game startGame.
	self assert: game phase equals: 'ready'.
	self allPlayers do: [ :p |
		self assert: (p hasReceived: 'gameStarted').
		self assert: (p hasReceived: 'biomass') ].
	self assert: (((alice lastMessageOfType: 'gameStarted') at: 'payload') at: 'role') equals: 'Household'.
	self assert: (((rose lastMessageOfType: 'gameStarted') at: 'payload') at: 'role') equals: 'Ranger'

