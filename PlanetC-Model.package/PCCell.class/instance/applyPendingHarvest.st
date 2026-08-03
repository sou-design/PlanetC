as yet unclassified
applyPendingHarvest
	biomassToApply >= 0 ifTrue: [
		self biomassLevel: biomassToApply.
		biomassToApply := -1 ]