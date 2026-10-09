tests
testFinishTheGame
	model currentRound: 3.
	self phase: 'ready'.
	self assert: game finish equals: 'ok'.
	self assert: game phase equals: 'ended'.
	self assert: model maxRounds equals: 2.
	self allPlayers do: [ :p | self assert: ((p lastMessageOfType: 'gameOver') at: 'rounds') equals: 2 ]







