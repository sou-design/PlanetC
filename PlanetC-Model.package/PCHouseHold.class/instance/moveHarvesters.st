as yet unclassified
moveHarvesters
	| nonEmptyCells |
	nonEmptyCells := self cormasModel cells select: [ :cell | cell isEmpty not ].
	children do: [ :harvester |
		harvester moveTo: (nonEmptyCells isEmpty
			ifTrue: [ self cormasModel cells atRandom ]
			ifFalse: [ nonEmptyCells atRandom ]) ]

