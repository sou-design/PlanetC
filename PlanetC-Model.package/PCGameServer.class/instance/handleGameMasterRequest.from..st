game master
handleGameMasterRequest: aDictionary from: aClient
	| type players reply answer canStart seconds |
	type := aDictionary at: 'type'.

	type = 'gmLogin' ifTrue: [
		(aDictionary at: 'secret' ifAbsent: [ nil ]) = PCGameMasterRole gameMasterSecret ifFalse: [
			aClient sendMessage: (Dictionary new at: 'type' put: 'gmRejected'; yourself).
			^ aClient disconnect ].
		(self clients select: [ :c | c role = PCGameMasterRole and: [ c ~~ aClient and: [ c isConnected ] ] ])
			do: [ :previous |
				previous sendMessage: (Dictionary new at: 'type' put: 'gmReplaced'; yourself).
				[ previous disconnect ] on: Error do: [ :e | ] ].
		aClient role: PCGameMasterRole.
		^ aClient sendMessage: (Dictionary new
			at: 'type' put: 'gmAccepted';
			at: 'addresses' put: self localNetworkAddresses;
			at: 'port' put: self portNumber;
			yourself) ].

	aClient role = PCGameMasterRole ifFalse: [ ^ self ].
	players := self clients reject: [ :c | c role = PCGameMasterRole ].
	canStart := players notEmpty and: [ players allSatisfy: #hasRole ].
	reply := Dictionary new at: 'type' put: type; yourself.
	answer := [ :result | aClient sendMessage: (reply at: 'result' put: result; yourself) ].

	type = 'gmPlayers' ifTrue: [
		reply
			at: 'phase' put: game phase;
			at: 'canStart' put: canStart;
			at: 'players' put: ((players sorted: [ :a :b | a name asLowercase <= b name asLowercase ])
				collect: [ :c |
					Dictionary new
						at: 'name' put: c name;
						at: 'connected' put: c isConnected;
						at: 'role' put: (c hasRole ifTrue: [ c role roleName asString ] ifFalse: [ nil ]);
						yourself ]).
		game phase = 'lobby' ifFalse: [
			reply
				at: 'round' put: game cormasModel currentRound;
				at: 'maxRounds' put: game cormasModel maxRounds ].
		^ aClient sendMessage: reply ].

	type = 'gmGrid' ifTrue: [
		game phase = 'lobby' ifFalse: [ game broadcastState ].
		game phase = 'householdsDone' ifTrue: [ game broadcastMoves ].
		^ self ].

	type = 'gmStart' ifTrue: [
		game phase = 'lobby' ifFalse: [ ^ answer value: 'alreadyStarted' ].
		canStart ifFalse: [ ^ answer value: 'missingRoles' ].
		game startGame.
		^ answer value: 'started' ].

	type = 'gmProceed' ifTrue: [
		seconds := (((aDictionary at: 'seconds' ifAbsent: [ 60 ]) asInteger) max: 5) min: 3600.
		^ answer value: (game proceed: seconds) ].

	type = 'gmFinish' ifTrue: [ ^ answer value: game finish ].

	type = 'gmMove' ifTrue: [
		^ answer value: (game
			changeMove: (aDictionary at: 'harvesterCells')
			ofHousehold: (aDictionary at: 'household')) ]