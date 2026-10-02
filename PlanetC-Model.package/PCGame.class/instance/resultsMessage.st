ui
resultsMessage
	^ Dictionary new
		at: 'type' put: 'results';
		at: 'rounds' put: self cormasModel currentRound - 1;
		at: 'families' put: (self cormasModel households asArray withIndexCollect: [ :household :index |
			| name gains |
			name := server nameFor: household.
			gains := household gains.
			Dictionary new
				at: 'name' put: (name isEmpty ifTrue: [ 'Family ' , index printString ] ifFalse: [ name ]);
				at: 'gains' put: gains asArray;
				at: 'total' put: (gains inject: 0 into: [ :sum :each | sum + each ]);
				yourself ]);
		yourself