initialization
startHouseholdsTurn: seconds
	| model round |
	model := self cormasModel.
	round := model currentRound.
	phase := 'householdsTurn'.
	[ [ | waited |
		server broadcast: (Dictionary new
			at: 'type' put: 'turn';
			at: 'round' put: round;
			at: 'turn' put: 'households';
			at: 'seconds' put: seconds;
			yourself).
		waited := 0.
		[ waited < (seconds * 1000) and: [ self allRequiredActionsSubmitted not ] ] whileTrue: [
			(Delay forMilliseconds: 500) wait.
			waited := waited + 500 ].
		model resolveRound.
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
			do: [ :e | Transcript showCr: 'Households turn crashed: ', e messageText ].
	phase := model currentRound > model maxRounds
		ifTrue: [ 'ended' ]
		ifFalse: [ 'ready' ] ] forkNamed: 'Households turn'