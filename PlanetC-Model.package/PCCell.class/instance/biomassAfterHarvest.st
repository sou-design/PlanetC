as yet unclassified
biomassAfterHarvest
	^ biomassToApply >= 0
		ifTrue: [ biomassToApply ]
		ifFalse: [ biomassLevel ]