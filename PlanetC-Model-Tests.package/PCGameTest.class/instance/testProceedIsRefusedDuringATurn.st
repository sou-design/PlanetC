tests
testProceedIsRefusedDuringATurn
	#( 'lobby' 'rangerTurn' 'householdsTurn' ) do: [ :phase |
		self phase: phase.
		self assert: (game proceed: 10) equals: 'notReady'.
		self assert: game phase equals: phase ]















