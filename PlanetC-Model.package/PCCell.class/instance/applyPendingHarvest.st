as yet unclassified
applyPendingHarvest
	pendingBiomassLevel ifNotNil: [
		self biomassLevel: pendingBiomassLevel.
		pendingBiomassLevel := nil ]