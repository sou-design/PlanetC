as yet unclassified
init
	<init>
	currentRound := 1.
	currentPhase := 1.
	submittedMoves := Dictionary new.
	submittedProtection := #().
	self createGridNumberOfRows: 4 numberOfColumns: 5 neighbourhood: 8 closed: true.
	self applyBiomassMatrix: self initialBiomassMatrix.
	self initializeHouseHolds.
	self initializeRanger.
	self initializeBirds .