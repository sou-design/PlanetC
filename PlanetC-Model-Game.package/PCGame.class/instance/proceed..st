accessing
proceed: seconds
	| model |
	model := self cormasModel.
	phase = 'householdsDone' ifTrue: [
		self resolveHouseholdsTurn.
		^ 'ok' ].
	phase = 'ended' ifTrue: [
		model maxRounds: model currentRound.
		phase := 'ready' ].
	phase = 'ready' ifTrue: [
		self beginNextRound.
		model currentRound = 1
			ifTrue: [ self startHouseholdsTurn: seconds ]
			ifFalse: [ phase := 'newBiomass' ].
		^ 'ok' ].
	phase = 'newBiomass' ifTrue: [
		self startRangerTurn: seconds.
		^ 'ok' ].
	phase = 'rangerDone' ifFalse: [ ^ 'notReady' ].
	self startHouseholdsTurn: seconds.
	^ 'ok'