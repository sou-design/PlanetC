results
broadcastResults
	| results |
	results := self resultsMessage.
	server clients do: [ :client |
		[ client role = PCGameMasterRole ifTrue: [ client sendMessage: results ].
		client role = PCHouseHoldRole ifTrue: [
			| household |
			household := self agentFor: client.
			client sendMessage: (Dictionary new
				at: 'type' put: 'roundResult';
				at: 'round' put: household gains size;
				at: 'gain' put: (household gains ifEmpty: [ 0 ] ifNotEmpty: [ :gains | gains last ]);
				at: 'total' put: household totalGain;
				yourself) ] ]
			on: Error
			do: [ :e | Transcript showCr: 'Could not send results to ', client name printString, ': ', e messageText ] ]