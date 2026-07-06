as yet unclassified
step
	<control>
	currentRound > 5 ifTrue: [ ^ self ].

	currentPhase = 1 ifTrue: [
		currentRound = 1 ifTrue: [ self initializeHouseHolds ].
		self cells do: [ :cell | cell regrowBiomass ].
		self installAdultBirds.
		self households do: [ :h | h leaveHarvesters ] ]. 

	currentPhase = 2 ifTrue: [
		self cells do: [ :cell | cell isProtected: false ].
		self rangers do: [ :ranger | ranger protectCells ] ].

	currentPhase = 3 ifTrue: [
		self households do: [ :h | h resetHarvest ].
		self households do: [ :h | h moveHarvesters ].      
		self cells do: [ :cell | cell collectHarvest ].
		self cells do: [ :cell | cell updateVisitState ].
		self cells do: [ :cell | cell updateNewbornBirds ] ].

	currentPhase = 3
		ifTrue: [ currentPhase := 1. currentRound := currentRound + 1 ]
		ifFalse: [ currentPhase := currentPhase + 1 ]