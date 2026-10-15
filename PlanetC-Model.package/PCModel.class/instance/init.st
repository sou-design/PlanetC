init
init
	<init>
	self makeAgentsScatteredInCells.
	currentStep := 1.
	submittedMoves := Dictionary new.
	self createGridNumberOfRows: 4 numberOfColumns: 5 neighbourhood: 8 closed: true.
	self applyBiomassMatrix: self initialBiomassMatrix.
	self initializeHouseholds.
	self initializeRanger.
