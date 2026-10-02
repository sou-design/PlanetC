results
broadcastResults
	"End of a round: each family receives only its own gain, the game master receives everyone's"
	| results |
	results := self resultsMessage.
	server clients do: [ :client |
		[ client role = PCGameMasterRole ifTrue: [ client sendMessage: results ].
		client role = PCHouseHoldRole ifTrue: [
			| gains |
			gains := (self agentFor: client) gains.
			client sendMessage: (Dictionary new
				at: 'type' put: 'roundResult';
				at: 'round' put: gains size;
				at: 'gain' put: (gains ifEmpty: [ 0 ] ifNotEmpty: [ :g | g last ]);
				at: 'total' put: (gains inject: 0 into: [ :sum :each | sum + each ]);
				yourself) ] ]
			on: Error
			do: [ :e | Transcript showCr: 'Could not send results to ', client name printString, ': ', e messageText ] ]