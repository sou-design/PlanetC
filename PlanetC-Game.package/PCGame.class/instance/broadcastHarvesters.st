broadcast
broadcastHarvesters
	server broadcast: (Dictionary new
		at: 'type' put: 'harvesters';
		at: 'values' put: (self cormasModel cells collect: [ :c |
			| counts |
			counts := Dictionary new.
			(c occupantsOfClass: PCHarvester) do: [ :h |
				| key |
				key := server nameFor: h household.
				counts at: key put: (counts at: key ifAbsent: [ 0 ]) + 1 ].
			counts associations collect: [ :assoc |
				Dictionary new
					at: 'household' put: assoc key;
					at: 'count' put: assoc value;
					yourself ] ]) asArray;
		yourself)