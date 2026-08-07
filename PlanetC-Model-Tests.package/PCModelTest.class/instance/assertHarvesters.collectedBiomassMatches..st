as yet unclassified
assertHarvesters: aCollectionOfHarvesters collectedBiomassMatches: anExpectedDescendingArray 
 
	| actual |
	actual := (aCollectionOfHarvesters collect: [ :h | h collectedBiomass ])
		asSortedCollection: [ :a :b | a > b ].
	self assert: actual asArray equals: anExpectedDescendingArray
