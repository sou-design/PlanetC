accessing
biomassAfterHarvest: aCell
	^ aCell biomassToApply >= 0
		ifTrue: [ aCell biomassToApply ]
		ifFalse: [ aCell biomassLevel ]