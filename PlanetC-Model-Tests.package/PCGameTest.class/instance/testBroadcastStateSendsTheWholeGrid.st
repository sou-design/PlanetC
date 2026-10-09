tests
testBroadcastStateSendsTheWholeGrid
	game broadcastState.
	self allPlayers do: [ :p |
		#( 'biomass' 'birds' 'protection' 'harvesters' ) do: [ :type |
			self assert: (p hasReceived: type) description: p name , ' should receive ' , type ] ].
	self assert: ((alice lastMessageOfType: 'biomass') at: 'values') size equals: 20




