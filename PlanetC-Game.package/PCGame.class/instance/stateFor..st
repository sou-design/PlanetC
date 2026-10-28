as yet unclassified
stateFor: aClient
	| model step isHousehold household hidden gains state |
	model := self cormasModel.
	step := model currentStep.
	isHousehold := aClient role = PCHouseHoldRole.
	isHousehold ifTrue: [ household := server agentFor: aClient ].

	hidden := phase = 'householdsTurn' or: [ phase = 'householdsDone' ].

	state := Dictionary new
		at: 'type' put: 'state';
		at: 'role' put: aClient role roleName;
		at: 'phase' put: phase;
		at: 'harvesterCount' put: (isHousehold ifTrue: [ household harvesters size ] ifFalse: [ 0 ]);
		at: 'round' put: ((#('newBiomass' 'rangerTurn' 'rangerDone' 'householdsTurn' 'householdsDone') includes: phase)
			ifTrue: [ step ]
			ifFalse: [ step - 1 ]);
		at: 'turn' put: (phase = 'rangerTurn'
			ifTrue: [ 'ranger' ]
			ifFalse: [ phase = 'householdsTurn' ifTrue: [ 'households' ] ifFalse: [ '' ] ]);
		at: 'secondsLeft' put: ((phase = 'rangerTurn' or: [ phase = 'householdsTurn' ])
			ifTrue: [ (turnEndsAt - DateAndTime now) asSeconds max: 0 ]
			ifFalse: [ 0 ]);
		at: 'submitted' put: (isHousehold and: [ householdsWithMove includes: household ]);
		at: 'biomass' put: (model cells collect: #biomassLevel) asArray;
		at: 'birds' put: (model cells collect: [ :c |
			Dictionary new
				at: 'adults' put: ((c occupantsOfClass: PCBird) count: [ :b | b state = #adult ]);
				at: 'newborns' put: ((c occupantsOfClass: PCBird) count: [ :b | b state = #newborn ]);
				yourself ]) asArray;
		at: 'protection' put: (model cells collect: [ :c |
			c isProtected and: [ isHousehold not or: [ phase ~= 'rangerTurn' ] ] ]) asArray;
		at: 'harvesters' put: (model cells collect: [ :c |
			| here mine |
			here := c occupantsOfClass: PCHarvester.
			mine := isHousehold
				ifTrue: [ here count: [ :h | h household == household ] ]
				ifFalse: [ 0 ].
			Dictionary new
				at: 'mine' put: mine;
				at: 'others' put: (hidden ifTrue: [ 0 ] ifFalse: [ here size - mine ]);
				yourself ]) asArray;
		yourself.

	"Game over: the final tables"
		finished ifTrue: [
		^ state
			at: 'finalResults' put: (self resultsMessage at: 'ranger' put: rangerRounds asArray; at: 'session'   put: session; yourself);
			yourself ].


	(isHousehold and: [ #('ready' 'newBiomass' 'ended') includes: phase ]) ifTrue: [
		gains := household gains.
		gains ifNotEmpty: [
			state at: 'roundResult' put: (Dictionary new
				at: 'round' put: gains size;
				at: 'gain' put: gains last;
				at: 'total' put: (gains inject: 0 into: [ :sum :each | sum + each ]);
				at: 'harvesters' put: (self harvesterResultsFor: household);
				yourself) ] ].
	^ state