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
		self initializeRanger.

		"Example of creating agents and randomly positioning them on a grid"
		
	"self createN: 3 randomlyLocatedEntities: YourAgentClass1.
	self createN: 3 randomlyLocatedAloneEntities: YourAgentClass2."