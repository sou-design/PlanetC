as yet unclassified
resolveRound
	submittedProtection
		ifNotEmpty: [
			submittedProtection do: [ :cellId | (self cells at: cellId) isProtected: true ] ].
	self households do: [ :h | h resetHarvest ].
	self households do: [ :h |
		(submittedMoves includesKey: h)
			ifTrue: [ h moveHarvestersTo: (submittedMoves at: h) ] ].
	submittedMoves := Dictionary new.
	submittedProtection := #().
	self cells do: [ :cell | cell collectHarvest ].
	self cells do: [ :cell | cell updateNonHarvestTime ].
	self cells do: [ :cell | cell updateNewbornBirds ].

	currentRound := currentRound + 1