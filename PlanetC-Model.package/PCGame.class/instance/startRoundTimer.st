as yet unclassified
startRoundTimer
	roundProcess ifNotNil: [ roundProcess terminate ].
	roundProcess := [
		[ [ self cormasModel currentRound <= self cormasModel maxRounds ] whileTrue: [
			| waited |
			self cormasModel beginRound.
			self broadcastRound.
			self broadcastBiomass.
			self broadcastBirds.
			self broadcastProtection.
			self broadcastHarvesters.
			self refreshCormasUI.

			(Delay forSeconds: 10) wait.

			waited := 0.
			[ waited < 120000 and: [ self allRequiredActionsSubmitted not ] ] whileTrue: [
				(Delay forMilliseconds: 500) wait.
				waited := waited + 500 ].

			self cormasModel resolveRound.
			self incrementCurrentTimeStep.
			self cormasModel removeDestroyedEntities.
			self recordData.
			self broadcastBiomass.
			self broadcastBirds.
			self broadcastProtection.
			self broadcastHarvesters.
			self refreshCormasUI.

			(Delay forSeconds: 10) wait ] ]
		on: Error do: [ :e | Transcript showCr: 'Round timer crashed: ', e messageText ] ] fork