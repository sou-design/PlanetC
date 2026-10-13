ui
resultsMessage
	| families |
	families := self cormasModel households asArray select: [ :household | (server nameFor: household) notEmpty ].
	^ Dictionary new
		at: 'type' put: 'results';
		at: 'rounds' put: self cormasModel currentRound - 1;
		at: 'families' put: (families collect: [ :household |
			| gains |
			gains := household gains.
			Dictionary new
				at: 'name' put: (server nameFor: household);
				at: 'gains' put: gains asArray;
				at: 'total' put: (gains inject: 0 into: [ :sum :each | sum + each ]);
				at: 'harvesters' put: (self harvesterResultsFor: household);
				yourself ]);
		yourself