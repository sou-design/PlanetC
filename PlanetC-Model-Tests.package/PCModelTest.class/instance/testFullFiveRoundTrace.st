tests
testFullFiveRoundTrace
	| expectedBiomass |
	expectedBiomass := #(2 3 2 1 0).
	expectedBiomass do: [ :expected |
		cell regrowBiomass.
		self assert: cell biomassLevel equals: expected ]