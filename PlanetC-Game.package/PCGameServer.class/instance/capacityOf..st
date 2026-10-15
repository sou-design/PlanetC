as yet unclassified
capacityOf: aRole
	^ aRole = PCRangerRole
		ifTrue: [ 1 ]
		ifFalse: [ 20 ]