initialization
initializeBirds
	| habitableCells chosen |
	habitableCells := self cells select: [ :cell | cell isFull ].
	chosen := habitableCells shuffled first: 3.
	chosen do: [ :cell |
		| bird |
		bird := self newEntity: PCBird.
		bird state: #adult. ]