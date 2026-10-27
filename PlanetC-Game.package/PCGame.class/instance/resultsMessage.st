ui
resultsMessage
	| families |
	families := self householdsWithPlayer.
	^ Dictionary new
		at: 'type' put: 'results';
		at: 'rounds' put: self cormasModel currentStep - 1;
		at: 'families' put: (families collect: [ :household |
			| gains |
			gains := household gains.
			Dictionary new
				at: 'name' put: (server nameFor: household);
				at: 'gains' put: gains asArray;
				at: 'total' put: household totalGain;
				at: 'harvesters' put: (self harvesterResultsFor: household);
				yourself ]);
		yourself