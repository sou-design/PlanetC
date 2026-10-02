accessing
proceed: seconds
	"Start the next turn. Answer 'ok' or 'notReady'"
	| model |
	model := self cormasModel.
	phase = 'ended' ifTrue: [
		model maxRounds: model currentRound.
		phase := 'ready' ].
	phase = 'ready' ifTrue: [
		self beginNextRound.
		model currentRound = 1
			ifTrue: [ self startHouseholdsTurn: seconds ]
			ifFalse: [ self startRangerTurn: seconds ].
		^ 'ok' ].
	phase = 'rangerDone' ifFalse: [ ^ 'notReady' ].
	self startHouseholdsTurn: seconds.
	^ 'ok'