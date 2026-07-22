as yet unclassified
regrowBiomass
	self hasHarvesters ifTrue: [ ^ self ].
	nonHarvestTime = 0
		ifTrue: [ self biomassLevel: (biomassLevel + 1 min: 3) ]
		ifFalse: [
			nonHarvestTime >= 2
				ifTrue: [ self biomassLevel: (biomassLevel - 1 max: 0) ] ]