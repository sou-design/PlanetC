as yet unclassified
init
	<init>
	self makeAgentsScatteredInCells.
	currentRound := 1.
	currentPhase := 1.
	self
		createGridNumberOfRows: 4
		numberOfColumns: 5
		neighbourhood: 8
		closed: true.

		self applyBiomassMatrix: self initialBiomassMatrix.
		self initializeHouseHolds.
		self initializeRanger.
		self initializeBirds .