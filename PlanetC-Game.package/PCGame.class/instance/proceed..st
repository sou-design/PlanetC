accessing
proceed: seconds
	| model |
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
			ifFalse: [ phase := 'newBiomass' ].
		^ 'ok' ].
	phase = 'newBiomass' ifTrue: [
		self startRangerTurn: seconds.
		^ 'ok' ].
	phase = 'rangerDone' ifFalse: [ ^ 'notReady' ].
	self startHouseholdsTurn: seconds.
	^ 'ok'