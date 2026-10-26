broadcast
broadcastHarvesters
	| message |
	message := Dictionary new
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
		yourself.
	(phase = 'householdsTurn' or: [ phase = 'householdsDone' ])
		ifTrue: [ server householdClients do: [ :c |
			c sendMessage: (Dictionary new
				at: 'type' put: 'harvesters';
				at: 'values' put: ((message at: 'values') collect: [ :entries |
					entries select: [ :e | (e at: 'household') = c name ] ]);
				yourself) ] ]
		ifFalse: [ server broadcast: message ]