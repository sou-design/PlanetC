as yet unclassified
applyActions
	self households do: [ :h | h resetHarvest ].
	self households do: [ :h |
		(submittedMoves includesKey: h)
			ifTrue: [ h moveHarvestersTo: (submittedMoves at: h) ] ].
	submittedMoves := Dictionary new.
	self cells do: [ :cell | cell collectHarvest ].
	self cells do: [ :cell | cell updateNonHarvestTime ].
	self cells do: [ :cell | cell updateNewbornBirds ].

	currentStep := currentStep + 1