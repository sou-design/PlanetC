game flow
startRangerTurn: seconds
	| round |
	round := self cormasModel currentRound.
	phase := 'rangerTurn'.
	[
		[ server broadcast: (Dictionary new
			at: 'type' put: 'turn';
			at: 'round' put: round;
			at: 'turn' put: 'ranger';
			at: 'seconds' put: seconds;
			yourself).
		(Delay forSeconds: seconds) wait.
		server broadcast: (Dictionary new
			at: 'type' put: 'turnEnded';
			at: 'round' put: round;
			at: 'turn' put: 'ranger';
			yourself) ]
			on: Error
			do: [ :e | Transcript showCr: 'Ranger turn crashed: ', e messageText ].
		phase := 'rangerDone' ] forkNamed: 'Ranger turn'