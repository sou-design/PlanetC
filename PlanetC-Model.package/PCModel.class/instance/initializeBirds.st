initialization
initializeBirds 
	| habitableCells chosen |
	habitableCells := self cells select: [ :cell | cell hasEnoughBiomass ].
	habitableCells do: [ :cell |
		(self newEntity: PCBird) moveTo: cell. ]
