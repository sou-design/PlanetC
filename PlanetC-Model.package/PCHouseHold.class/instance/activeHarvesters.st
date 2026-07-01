as yet unclassified
activeHarvesters 
	^ children select: [ :h | h cell isNotNil ]
