tests
testBiomassValues
	game broadcastBiomass.
	self assert: ((alice lastMessageOfType: 'biomass') at: 'values') asArray equals: (model cells collect: [ :c | c biomassLevel ]) asArray


