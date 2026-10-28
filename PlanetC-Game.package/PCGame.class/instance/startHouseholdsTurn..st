game flow
startHouseholdsTurn: seconds
	| round |
	householdsWithMove := Set new.
	round := self cormasModel currentStep.
	phase := 'householdsTurn'.
	turnEndsAt := DateAndTime now + seconds seconds.
	[ [ | waited |
		server broadcast: (Dictionary new
			at: 'type' put: 'turn';
			at: 'round' put: round;
			at: 'turn' put: 'households';
			at: 'seconds' put: seconds;
			yourself).

		server publishState.
		waited := 0.
		[ waited < (seconds * 1000) and: [ self allRequiredActionsSubmitted not ] ] whileTrue: [
			(Delay forMilliseconds: 500) wait.
			waited := waited + 500 ].
		phase := 'householdsDone'.
		server broadcast: (Dictionary new
			at: 'type' put: 'turnEnded';
			at: 'round' put: round;
			at: 'turn' put: 'households';
			yourself).
		self broadcastMoves.
		self broadcastState ]
			on: Error
			do: [ :e |
				phase := 'householdsDone'.
				Transcript showCr: 'Households turn crashed: ', e messageText ] ] forkNamed: 'Households turn'