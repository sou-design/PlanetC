initialization
resolveHouseholdsTurn
	| model round |
	model := self cormasModel.
	round := model currentRound.
	[ model resolveRound.
	model households do: [ :household | household recordGain ].
	self incrementCurrentTimeStep.
	model removeDestroyedEntities.
	self recordData.
	self broadcastState.
	self broadcastResults.
	server broadcast: (Dictionary new
		at: 'type' put: 'roundEnded';
		at: 'round' put: round;
		at: 'maxRounds' put: model maxRounds;
		yourself) ]
		on: Error
		do: [ :e | Transcript showCr: 'Round resolution crashed: ', e messageText ].
	phase := model currentRound > model maxRounds
		ifTrue: [ 'ended' ]
		ifFalse: [ 'ready' ]