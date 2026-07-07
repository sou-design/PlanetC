as yet unclassified
regrowBiomass
	self hasHarvesters ifTrue: [ ^ self ].
	visitState = #leftOnce ifTrue: [ self biomassLevel: biomassLevel + 1 ].
	visitState = #abandoned     ifTrue: [ self biomassLevel: biomassLevel - 1 ]