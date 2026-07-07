as yet unclassified
updateNewbornBirds
	| disturbedCount disturbanceRate |
	self hasEnoughBiomass ifFalse: [ nbNewBorns := 0. ^ self ].
	self hasHarvesters ifTrue: [ nbNewBorns := 0. ^ self ].
	disturbedCount := self neighbourhood count: [ :c | c hasHarvesters ].
	disturbanceRate := disturbedCount / self neighbourhood size asFloat.
	nbNewBorns := disturbanceRate >= 0.5
		ifTrue:  [ 0 ]
		ifFalse: [ disturbanceRate > 0.2
			ifTrue:  [ 1 ]
			ifFalse: [ 2 ] ].

	1 to: nbNewBorns do: [ :i |
		| bird |
		bird := self cormasModel newEntity: PCBird.
		bird state: #newborn.
		bird moveTo: self ]