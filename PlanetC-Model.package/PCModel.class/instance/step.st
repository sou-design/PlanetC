as yet unclassified
step
	<control>
	currentRound > maxRounds ifTrue: [ ^ self ].
	self beginRound.
	self resolveRound