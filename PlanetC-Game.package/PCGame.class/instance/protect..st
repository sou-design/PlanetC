game flow
protect: cellIds
	self cormasModel currentStep = 1 ifTrue: [ ^ self ].
	self cormasModel rangers first protect: cellIds.
	self refreshCormasUI.
	self broadcastProtection.
	phase = 'rangerTurn' ifTrue: [ phase := 'rangerDone' ].
	server publishState.