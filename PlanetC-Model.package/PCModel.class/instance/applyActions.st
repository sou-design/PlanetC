as yet unclassified
applyActions
	self households do: [ :h | h resetHarvest ].
	self cells do: [ :cell | cell collectHarvest ].
	self cells do: [ :cell | cell updateNonHarvestTime ].
	self cells do: [ :cell | cell updateNewbornBirds ].
	self cells do: [ :cell | cell applyPendingHarvest ].
	self cells do: [ :cell | cell regrowBiomass ].
	currentStep := currentStep + 1