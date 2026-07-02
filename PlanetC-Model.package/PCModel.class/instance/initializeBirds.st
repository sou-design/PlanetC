initialization
initializeBirds 
	| habitableCells chosen |
	habitableCells := self cells select: [ :cell | cell isFull ].
	chosen := habitableCells shuffled first: 3.
	chosen do: [ :cell |
		(self newEntity: PCBird) moveTo: cell.
		cell nbNewBorns: 1 ]
