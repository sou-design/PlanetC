game flow
catchUp: aClient
	| household gains |
	(phase = 'lobby' or: [ aClient hasRole not ]) ifTrue: [ ^ self ].

	"Role and game screen"
	aClient sendGameStartedMessage.

	"Grid"
	self broadcastState.

	"Game over: final results for everyone, nothing else"
	finished ifTrue: [
		^ aClient sendMessage: (self resultsMessage
			at: 'type' put: 'gameOver';
			at: 'ranger' put: rangerRounds asArray;
			yourself) ].

	"Last round result, only while it is still shown to the others"
	((#('ready' 'newBiomass' 'ended') includes: phase)
		and: [ aClient role = PCHouseHoldRole ]) ifTrue: [
			household := server agentFor: aClient.
			gains := household gains.
			gains ifNotEmpty: [
				aClient sendMessage: (Dictionary new
					at: 'type' put: 'roundResult';
					at: 'round' put: gains size;
					at: 'gain' put: gains last;
					at: 'total' put: (gains inject: 0 into: [ :sum :each | sum + each ]);
					at: 'harvesters' put: (self harvesterResultsFor: household);
					yourself) ] ].

	"A turn is running: send it again with the time left"
	(phase = 'rangerTurn' or: [ phase = 'householdsTurn' ]) ifTrue: [
		aClient sendMessage: (Dictionary new
			at: 'type' put: 'turn';
			at: 'round' put: self cormasModel currentStep;
			at: 'turn' put: (phase = 'rangerTurn' ifTrue: [ 'ranger' ] ifFalse: [ 'households' ]);
			at: 'seconds' put: ((turnEndsAt - DateAndTime now) asSeconds max: 0);
			yourself) ]