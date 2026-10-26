game flow
catchUp: aClient
	(phase = 'lobby' or: [ aClient hasRole not ]) ifTrue: [ ^ self ].

	"Role and game screen"
	aClient sendGameStartedMessage.

	"Grid"
	self broadcastState.

	"A turn is running: send it again with the time left"
	(phase = 'rangerTurn' or: [ phase = 'householdsTurn' ]) ifTrue: [
		aClient sendMessage: (Dictionary new
			at: 'type' put: 'turn';
			at: 'round' put: self cormasModel currentStep;
			at: 'turn' put: (phase = 'rangerTurn' ifTrue: [ 'ranger' ] ifFalse: [ 'households' ]);
			at: 'seconds' put: ((turnEndsAt - DateAndTime now) asSeconds max: 0);
			yourself) ]