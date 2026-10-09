tests
testHouseholdsMoveOnlyDuringTheirTurn
	#( 'ready' 'rangerTurn' 'householdsDone' ) do: [ :phase |
		self phase: phase.
		self send: (self moveTo: #( 1 2 3 4 )) from: alice ].
	self assert: (self householdOf: alice) activeHarvesters isEmpty










