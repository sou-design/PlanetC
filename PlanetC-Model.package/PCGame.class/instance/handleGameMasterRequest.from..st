game master
handleGameMasterRequest: aDictionary from: aClient
	| type players model reply seconds |
	type := aDictionary at: 'type' ifAbsent: [ ^ self ].

	type = 'gmLogin' ifTrue: [
		(aDictionary at: 'secret' ifAbsent: [ nil ]) = PCGameMasterRole gameMasterSecret ifFalse: [
			aClient sendMessage: (Dictionary new at: 'type' put: 'gmRejected'; yourself).
			^ aClient disconnect ].
		(server clients select: [ :c | c role = PCGameMasterRole and: [ c ~~ aClient and: [ c isConnected ] ] ])
			do: [ :previous |
				previous sendMessage: (Dictionary new at: 'type' put: 'gmReplaced'; yourself).
				[ previous disconnect ] on: Error do: [ :e | ] ].
		aClient role: PCGameMasterRole.
		^ aClient sendMessage: (Dictionary new
			at: 'type' put: 'gmAccepted';
			at: 'addresses' put: server localNetworkAddresses;
			at: 'port' put: server portNumber;
			yourself) ].

	aClient role = PCGameMasterRole ifFalse: [ ^ self ].
	players := server clients reject: [ :c | c role = PCGameMasterRole ].
	model := self cormasModel.
	reply := Dictionary new at: 'type' put: type; yourself.

	type = 'gmPlayers' ifTrue: [
		reply
			at: 'phase' put: phase;
			at: 'canStart' put: (players notEmpty and: [ players allSatisfy: #hasRole ]);
			at: 'players' put: ((players asSortedCollection: [ :a :b | a name asLowercase <= b name asLowercase ])
				asArray collect: [ :c |
					Dictionary new
						at: 'name' put: c name;
						at: 'connected' put: c isConnected;
						at: 'role' put: (c hasRole ifTrue: [ c role roleName asString ] ifFalse: [ nil ]);
						yourself ]).
		phase = 'lobby' ifFalse: [
			reply
				at: 'round' put: model currentRound;
				at: 'maxRounds' put: model maxRounds ].
		^ aClient sendMessage: reply ].

	type = 'gmGrid' ifTrue: [
		phase = 'lobby' ifFalse: [ self broadcastBiomass; broadcastBirds; broadcastProtection; broadcastHarvesters ].
		^ self ].

	type = 'gmStart' ifTrue: [
		reply at: 'result' put: (phase = 'lobby'
			ifFalse: [ 'alreadyStarted' ]
			ifTrue: [
				(players notEmpty and: [ players allSatisfy: #hasRole ])
					ifTrue: [ self startGame. 'started' ]
					ifFalse: [ 'missingRoles' ] ]).
		^ aClient sendMessage: reply ].

	type = 'gmProceed' ifTrue: [
		seconds := (((aDictionary at: 'seconds' ifAbsent: [ 60 ]) asInteger) max: 5) min: 3600.
		phase = 'ended' ifTrue: [
			model maxRounds: model currentRound.
			phase := 'ready' ].
		phase = 'ready' ifTrue: [
			self beginNextRound.
			model currentRound = 1
				ifTrue: [ self startHouseholdsTurn: seconds ]
				ifFalse: [ self startRangerTurn: seconds ].
			^ aClient sendMessage: (reply at: 'result' put: 'ok'; yourself) ].
		phase = 'rangerDone' ifTrue: [
			self startHouseholdsTurn: seconds.
			^ aClient sendMessage: (reply at: 'result' put: 'ok'; yourself) ].
		^ aClient sendMessage: (reply at: 'result' put: 'notReady'; yourself) ].

	type = 'gmFinish' ifTrue: [
		((phase = 'ready' or: [ phase = 'ended' ]) and: [ model currentRound > 1 ]) ifFalse: [
			^ aClient sendMessage: (reply at: 'result' put: 'notReady'; yourself) ].
		model maxRounds: model currentRound - 1.
		phase := 'ended'.
		server broadcast: (Dictionary new
			at: 'type' put: 'gameOver';
			at: 'rounds' put: model currentRound - 1;
			yourself).
		^ aClient sendMessage: (reply at: 'result' put: 'ok'; yourself) ]