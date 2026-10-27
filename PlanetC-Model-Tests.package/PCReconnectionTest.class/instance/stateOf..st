as yet unclassified
stateOf: aFakeWebSocket
	^ (aFakeWebSocket messages select: [ :each | (each at: 'type' ifAbsent: [ '' ]) = 'state' ]) last