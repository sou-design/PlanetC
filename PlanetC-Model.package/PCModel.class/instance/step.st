as yet unclassified
step
	<control>
	currentRound > maxRounds ifTrue: [ ^ self ].

	currentPhase = 1 ifTrue: [
		self cells do: [ :cell | cell isProtected: false ].
		self cells do: [ :cell | cell applyPendingHarvest ].
		currentRound = 1 ifFalse: [
			self cells do: [ :cell | cell regrowBiomass ] ].
		self installAdultBirds.
		self households do: [ :h | h leaveHarvesters ] ].

	currentPhase = 2 ifTrue: [
		self cells do: [ :cell | cell isProtected: false ].
		submittedProtection isEmpty
			ifFalse: [
				submittedProtection do: [ :cellId | (self cells at: cellId) isProtected: true ].
				submittedProtection := #() ]
			ifTrue: [ self rangers do: [ :ranger | ranger protectCells ] ] ].

	currentPhase = 3 ifTrue: [
		self households do: [ :h | h resetHarvest ].
		self households do: [ :h |
			(submittedMoves includesKey: h)
				ifTrue: [ h moveHarvestersTo: (submittedMoves at: h) ]
				ifFalse: [
					(self households anySatisfy: [ :any | any name notNil ])
						ifFalse: [ h moveHarvesters ] ] ].
		submittedMoves := Dictionary new.
		self cells do: [ :cell | cell collectHarvest ].
		self cells do: [ :cell | cell updateNonHarvestTime ].
		self cells do: [ :cell | cell updateNewbornBirds ] ].

	currentPhase = 3
		ifTrue: [ currentPhase := 1. currentRound := currentRound + 1 ]
		ifFalse: [ currentPhase := currentPhase + 1 ]