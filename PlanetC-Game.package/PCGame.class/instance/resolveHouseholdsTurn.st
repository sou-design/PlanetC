broadcast
resolveHouseholdsTurn
	| model round |
	model := self cormasModel.
	round := model currentStep.
	[ model applyActions.
	model households do: [ :household | household recordGain ].
	rangerRounds add: (Dictionary new
		at: 'round' put: round;
		at: 'protected' put: ((model cells select: #isProtected) collect: [ :c | model cells indexOf: c ]) asArray;
		at: 'newborns' put: model totalNewborns;
		yourself).
	self incrementCurrentTimeStep.
	phase := model currentStep > model maxSteps
		ifTrue: [ 'ended' ]
		ifFalse: [ 'ready' ].
	model removeDestroyedEntities.
	self recordData.
	self broadcastState.
	self broadcastResults.
	server broadcast: (Dictionary new
		at: 'type' put: 'roundEnded';
		at: 'round' put: round;
		at: 'maxRounds' put: model maxSteps;
		yourself).
	self saveData: [ recorder saveRound: round of: self ] ]
		on: Error
		do: [ :e | Transcript showCr: 'Round resolution crashed: ', e messageText ]