stepping
step
	<control>
	currentRound > maxRounds ifTrue: [ ^ self ].
	self beginRound.
	self resolveRound