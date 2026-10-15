as yet unclassified
updateEnvironment
	self cells do: [ :cell | cell isProtected: false ].
	self cells do: [ :cell | cell applyPendingHarvest ].
	currentStep = 1 ifFalse: [
		self cells do: [ :cell | cell regrowBiomass ] ].
	self installAdultBirds.
	self households do: [ :h | h leaveHarvesters ]