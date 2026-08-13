as yet unclassified
broadcastHarvesters
	server broadcast: (Dictionary new
		at: 'type' put: 'harvesters';
		at: 'values' put: (self cormasModel cells collect: [ :c |
			(c occupantsOfClass: PCHarvester) size ]) asArray;
		yourself)