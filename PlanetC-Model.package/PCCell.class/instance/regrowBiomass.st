as yet unclassified
regrowBiomass
	self hasHarvesters ifTrue: [ ^ self ].
	visitState = #leftLastRound ifTrue: [ self biomassLevel: biomassLevel + 1 ].
	visitState = #abandoned     ifTrue: [ self biomassLevel: biomassLevel - 1 ]