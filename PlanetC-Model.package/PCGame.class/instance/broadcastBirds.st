initialization
broadcastBirds
	server broadcast: (Dictionary new
		at: 'type' put: 'birds';
		at: 'values' put: (self cormasModel cells collect: [ :c | (c occupantsOfClass: PCBird) size ]) asArray;
		yourself)