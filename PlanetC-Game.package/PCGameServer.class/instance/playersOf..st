as yet unclassified
playersOf: aRole
	^ self clients select: [ :c | c role = aRole ]