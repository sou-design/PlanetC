helper methods
activeHarvesters 
	^ children select: [ :h | h cell isNotNil ]
