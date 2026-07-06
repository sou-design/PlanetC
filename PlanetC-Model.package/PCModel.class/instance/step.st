as yet unclassified
"step

	<control>
	""self households do: [ :household | household resetHarvest ].""
	self households do: [ :household | household moveHarvesters ].

	""2. cells handle biomass and birds""
	self cells do: [ :cell | cell updateVisitState ].
	self cells do: [ :cell | cell updateBiomass ].
	self cells do: [ :cell | cell updateNewbornBirds ].
	self cells do: [ :cell | cell isProtected: false ].
	self rangers do: [ :ranger | ranger protectCells ]."
step 
	<control>
	currentRound = 1 ifTrue: [ self initializeHouseHolds ].
	
	self cells do: [ :cell | cell updateNewbornBirds ].

		currentRound > 1 ifTrue: [
		self cells do: [ :cell | cell updateBiomass ].
		self cells do: [ :cell | cell isProtected: false ].
		self rangers do: [ :ranger | ranger protectCells ] 
		
		].
		self households do: [ :h | h resetHarvest ].
		self households do: [ :h | h moveHarvesters ].

		
		self cells do: [ :cell | cell updateVisitState ].
	
		currentRound := currentRound + 1.
