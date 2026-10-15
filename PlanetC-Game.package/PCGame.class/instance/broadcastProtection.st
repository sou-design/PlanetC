broadcast
broadcastProtection
	server broadcast: (Dictionary new
		at: 'type' put: 'protection';
		at: 'values' put: (self cormasModel cells collect: #isProtected) asArray;
		yourself)