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
		phase := 'regenerated' ].
	phase = 'ready' ifTrue: [
		model currentStep = 1 ifTrue: [
			self beginNextRound.
			self startHouseholdsTurn: seconds.
			^ 'ok' ].
		"End of the round: regenerate the biomass, send the harvesters home, update the birds"
		model cells do: [ :c | c applyPendingHarvest ].
		model cells do: [ :c | c regrowBiomass ].
		model households do: [ :h | h leaveHarvesters ].
		model installAdultBirds.
		model removeDestroyedEntities.
		rangerRounds ifNotEmpty: [ rangerRounds last at: 'biomass' put: model biomass ].
		phase := model currentStep > model maxSteps
			ifTrue: [ 'ended' ]
			ifFalse: [ 'regenerated' ].
		self broadcastState.
		server broadcast: (Dictionary new
			at: 'type' put: 'regenerated';
			at: 'round' put: model currentStep - 1;
			at: 'maxRounds' put: model maxSteps;
			yourself).
		server broadcast: self resultsMessage.
		^ 'ok' ].
	phase = 'regenerated' ifTrue: [
		"Switch to the new round first: a phone that reloads now must not go back to the regeneration"
		phase := 'newBiomass'.
		self beginNextRound.
		self startRangerTurn: seconds.
		^ 'ok' ].
	phase = 'newBiomass' ifTrue: [
		self startRangerTurn: seconds.
		^ 'ok' ].
	phase = 'rangerDone' ifFalse: [ ^ 'notReady' ].
	self startHouseholdsTurn: seconds.
	^ 'ok'