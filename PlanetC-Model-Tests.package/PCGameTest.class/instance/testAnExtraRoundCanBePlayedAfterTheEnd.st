tests
testAnExtraRoundCanBePlayedAfterTheEnd
	model maxRounds: 1.
	model currentRound: 2.
	self phase: 'ended'.
	self assert: (game proceed: 30) equals: 'ok'.
	self assert: model maxRounds equals: 2.
	self assert: game phase equals: 'newBiomass'

