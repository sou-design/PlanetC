as yet unclassified
beginRound
	self cells do: [ :cell | cell isProtected: false ].
	self cells do: [ :cell | cell applyPendingHarvest ].
	currentRound = 1 ifFalse: [
		self cells do: [ :cell | cell regrowBiomass ] ].
	self installAdultBirds.
	self households do: [ :h | h leaveHarvesters ]