as yet unclassified
applyActions
	self households do: [ :h | h resetHarvest ].
	self cells do: [ :cell | cell collectHarvest ].
	self cells do: [ :cell | cell updateNonHarvestTime ].
	self cells do: [ :cell | cell updateNewbornBirds ].
	currentStep := currentStep + 1