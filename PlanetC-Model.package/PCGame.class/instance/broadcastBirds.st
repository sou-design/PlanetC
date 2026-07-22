initialization
broadcastBirds
	server broadcast: (Dictionary new
		at: 'type' put: 'birds';
		at: 'values' put: (self cormasModel cells collect: [ :c |
			Dictionary new
				at: 'adults' put: ((c occupantsOfClass: PCBird) count: [ :b | b state = #adult ]);
				at: 'newborns' put: ((c occupantsOfClass: PCBird) count: [ :b | b state = #newborn ]);
				yourself ]) asArray;
		yourself)
