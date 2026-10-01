ui
resultsMessage
	^ Dictionary new
		at: 'type' put: 'results';
		at: 'rounds' put: self cormasModel currentRound - 1;
		at: 'families' put: (self cormasModel households asArray withIndexCollect: [ :household :index |
			| name |
			name := self nameFor: household.
			Dictionary new
				at: 'name' put: (name isEmpty ifTrue: [ 'Family ' , index printString ] ifFalse: [ name ]);
				at: 'gains' put: household gains asArray;
				at: 'total' put: household totalGain;
				yourself ]);
		yourself