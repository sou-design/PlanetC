as yet unclassified
updateNewbornBirds 
	| disturbedCount disturbanceRate |
	
	"remove existing birds"
	(self occupantsOfClass: PCBird) do: [ :b | b leave ].
	
	"cell must be habitable"
	self hasEnoughBiomass ifFalse: [ nbNewBorns := 0. ^ self ].
	
	"harvesters on cell → no breeding"
	self hasHarvesters ifTrue: [ nbNewBorns := 0. ^ self ].
	
	"calculate disturbance rate from neighbours"
	disturbedCount := self neighbourhood count: [ :c | c hasHarvesters ].
	disturbanceRate := disturbedCount / self neighbourhood size asFloat.
	
	"apply breeding rules"
	nbNewBorns := disturbanceRate > 0.5
		ifTrue:  [ 0 ]
		ifFalse: [ disturbanceRate > 0.2
			ifTrue:  [ 1 ]
			ifFalse: [ 2 ] ].
	
	"create bird agents"
	1 to: nbNewBorns do: [ :i |
		(self cormasModel newEntity: PCBird) moveTo: self ]
