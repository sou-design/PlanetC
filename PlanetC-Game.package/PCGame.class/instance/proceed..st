accessing
proceed: seconds
	| model |
	finished := false.
	model := self cormasModel.
	phase = 'householdsDone' ifTrue: [
		self resolveHouseholdsTurn.
		^ 'ok' ].
	phase = 'ended' ifTrue: [
		model maxSteps: model currentStep.
		phase := 'ready' ].
	phase = 'ready' ifTrue: [
		self beginNextRound.
		model currentStep = 1
			ifTrue: [ self startHouseholdsTurn: seconds ]
			ifFalse: [ phase := 'newBiomass'. server publishState. ].
		^ 'ok' ].
	phase = 'newBiomass' ifTrue: [
		self startRangerTurn: seconds.
		^ 'ok' ].
	phase = 'rangerDone' ifFalse: [ ^ 'notReady' ].
	self startHouseholdsTurn: seconds.
	^ 'ok'