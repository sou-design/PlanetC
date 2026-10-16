initialization
recordRangerRound: round

	| model |
	model := self cormasModel.
	rangerRounds add: (Dictionary new
		at: 'round' put: round;
		at: 'protected' put: ((model cells select: #isProtected) collect: [ :c | model cells indexOf: c ]) asArray;
		at: 'newborns' put: model totalNewborns;
		yourself)