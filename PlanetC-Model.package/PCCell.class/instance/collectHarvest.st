as yet unclassified
collectHarvest
	| harvesters shuffled |
	harvesters := self occupantsOfClass: PCHarvester.
	harvesters isEmpty ifTrue: [ ^ self ].

	harvesters size = 1 ifTrue: [
		self isEmpty ifTrue: [ ^ self ].
		self hasEnoughBiomass
			ifTrue:  [ harvesters first collect: 2 ]
			ifFalse: [ harvesters first collect: 1 ].
		^ self ].

	self isEmpty ifTrue: [ ^ self ].
	shuffled := harvesters shuffled.
	self isFull
		ifTrue: [
			(shuffled at: 1) collect: 2.
			(shuffled at: 2) collect: 1.
			self biomassLevel: (harvesters size = 2 ifTrue: [ 1 ] ifFalse: [ 0 ]) ]
		ifFalse: [
			shuffled first collect: biomassLevel.
			self biomassLevel: 0 ]