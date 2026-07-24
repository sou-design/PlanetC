as yet unclassified
startRoundTimer
	roundProcess ifNotNil: [ roundProcess terminate ].
	roundProcess := [
		[ [ self cormasModel currentRound <= self cormasModel maxRounds ] whileTrue: [
			| waited maxWait |
			waited := 0.
			self cormasModel currentPhase = 1
				ifTrue: [ (Delay forSeconds: 10) wait ]
				ifFalse: [
					maxWait := self cormasModel currentPhase = 2
						ifTrue: [ 10000 ]
						ifFalse: [ 120000 ].
					[ waited < maxWait and: [ self allRequiredActionsSubmitted not ] ] whileTrue: [
						(Delay forMilliseconds: 500) wait.
						waited := waited + 500 ] ].
			self runStep ] ]
			on: Error do: [ :e | Transcript showCr: 'Round timer crashed: ', e messageText ] ] fork