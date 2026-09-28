moving
moveHarvesters
	| nonEmptyCells |
	nonEmptyCells := self cormasModel cells select: [ :cell | cell isEmpty not ].
	children do: [ :harvester | harvester moveTo: nonEmptyCells atRandom ]
		

